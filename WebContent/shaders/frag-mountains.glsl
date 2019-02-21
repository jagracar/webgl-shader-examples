#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

// Common varyings
varying vec3 v_position;
varying vec3 v_normal;

/*
 *  Calculates the normal vector at the given position
 *
 *  Uses this fix for some mobiles:
 *  https://stackoverflow.com/questions/20272272/standard-derivatives-from-fragment-shader-dfdx-dfdy-dont-run-correctly-in-a
 */
vec3 calculateNormal(vec3 position) {
    vec3 fdx = vec3(dFdx(position.x), dFdx(position.y), dFdx(position.z));
    vec3 fdy = vec3(dFdy(position.x), dFdy(position.y), dFdy(position.z));
    vec3 normal = normalize(cross(fdx, fdy));

    if (!gl_FrontFacing) {
        normal = -normal;
    }

    return normal;
}

/*
 *  Calculates the diffuse factor produced by the light illumination
 */
float diffuseFactor(vec3 normal, vec3 light_direction) {
    float df = dot(normalize(normal), normalize(light_direction));

    if (gl_FrontFacing) {
        df = -df;
    }

    return max(0.0, df);
}

// The plane tile size, the maximum mountain height and the sky color
uniform float u_tileSize;
uniform float u_maxHeight;
uniform vec3 u_skyColor;

// Varying containing the terrain elevation
varying float v_elevation;

/*
 * The main program
 */
void main() {
	// Calculate the new normal vector
	vec3 new_normal = calculateNormal(v_position);

	// Use the mouse position to define the light direction
	float min_resolution = min(u_resolution.x, u_resolution.y);
	vec3 light_direction = -vec3((u_mouse - 0.5 * u_resolution) / min_resolution, 0.25);

	// Set the default surface color
	vec3 surface_color = vec3(0.3, 0.65, 0.0);

	// Change the color for the snow peaks and the lakes
	if (v_elevation > 0.85 * u_maxHeight) {
		surface_color = vec3(1.0, 1.0, 1.0);
	} else if (v_elevation < 0.2 * u_maxHeight) {
		surface_color = vec3(0.3, 0.7, 0.9);
	}

	// Apply the light diffusion factor
	surface_color *= diffuseFactor(new_normal, light_direction);

	// Add a fog effect
	float fog_factor = clamp(0.0, 1.0, -(1.0 - u_mouse.y / u_resolution.y) * v_position.z / (15.0 * u_tileSize));
	surface_color = mix(surface_color, u_skyColor, fog_factor);

	// Fragment shader output
	gl_FragColor = vec4(surface_color, 1.0);
}
