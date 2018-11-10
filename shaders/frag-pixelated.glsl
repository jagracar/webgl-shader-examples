#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")

/*
 * The main program
 */
void main() {
	// Calculate the square size in pixel units based on the mouse position
	float square_size = floor(2.0 + 30.0 * (u_mouse.x / u_resolution.x));

	// Calculate the square center and corners
	vec2 center = square_size * floor(v_uv * u_resolution / square_size) + square_size * vec2(0.5, 0.5);
	vec2 corner1 = center + square_size * vec2(-0.5, -0.5);
	vec2 corner2 = center + square_size * vec2(+0.5, -0.5);
	vec2 corner3 = center + square_size * vec2(+0.5, +0.5);
	vec2 corner4 = center + square_size * vec2(-0.5, +0.5);

	// Calculate the average pixel color
	vec3 pixel_color = 0.4 * texture2D(u_texture, center / u_resolution).rgb;
	pixel_color += 0.15 * texture2D(u_texture, corner1 / u_resolution).rgb;
	pixel_color += 0.15 * texture2D(u_texture, corner2 / u_resolution).rgb;
	pixel_color += 0.15 * texture2D(u_texture, corner3 / u_resolution).rgb;
	pixel_color += 0.15 * texture2D(u_texture, corner4 / u_resolution).rgb;

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
