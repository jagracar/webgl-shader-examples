#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Common varyings
varying vec3 v_position;
varying vec3 v_normal;

/*
 *  Calculates the diffuse factor produced by the light illumination
 */
float diffuse_factor_1540259130(vec3 normal, vec3 light_direction) {
    return -dot(normalize(normal), normalize(light_direction));
}

/*
 * The main program
 */
void main() {
    // Use the mouse position to define the light direction
    float min_resolution = min(u_resolution.x, u_resolution.y);
    vec3 light_direction = -vec3((u_mouse - 0.5 * u_resolution) / min_resolution, 0.25);

    // Set the sphere surface color
    vec3 sphere_color = vec3(0.5 + 0.5 * cos(2.0 * v_position.y + 3.0 * u_time));

    // Apply the light diffusion factor
    sphere_color *= diffuse_factor_1540259130(v_normal, light_direction);

    // Fragment shader output
    gl_FragColor = vec4(sphere_color, 1.0);
}
