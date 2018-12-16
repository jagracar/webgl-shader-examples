#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")
#pragma glslify: calculateNormal = require("./requires/calculateNormal")
#pragma glslify: diffuseFactor = require("./requires/diffuseFactor")

/*
 * The main program
 */
void main() {
	// Calculate the new normal vector
	vec3 new_normal = calculateNormal(v_position);

	// Use the mouse position to define the light direction
	float min_resolution = min(u_resolution.x, u_resolution.y);
	vec3 light_direction = -vec3((u_mouse - 0.5 * u_resolution) / min_resolution, 0.25);

	// Set the surface color
	vec3 surface_color = vec3(1.0);

	// Apply the light diffusion factor
	surface_color *= diffuseFactor(new_normal, light_direction);

	// Fragment shader output
	gl_FragColor = vec4(surface_color, 1.0);
}
