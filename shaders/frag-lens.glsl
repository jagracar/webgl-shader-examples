#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")

/*
 * The main program
 */
void main() {
	// Set the lens radius
	float lens_radius = min(0.3 * u_resolution.x, 250.0);

	// Calculate the direction to the mouse position and the distance
	vec2 mouse_direction = u_mouse - gl_FragCoord.xy;
	float mouse_distance = length(mouse_direction);

	// Calculate the pixel color based on the mouse position
	vec3 pixel_color;

	if (mouse_distance < lens_radius) {
		// Calculate the pixel offset
		float exp = 1.0;
		vec2 offset = (1.0 - pow(mouse_distance / lens_radius, exp)) * mouse_direction;

		// Get the pixel color at the offset position
		pixel_color = texture2D(u_texture, v_uv + offset / u_resolution).rgb;
	} else {
		// Use the original image pixel color
		pixel_color = texture2D(u_texture, v_uv).rgb;
	}

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
