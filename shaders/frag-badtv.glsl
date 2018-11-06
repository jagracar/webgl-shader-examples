#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")
#pragma glslify: random_1d = require("./requires/random1d")
#pragma glslify: random_2d = require("./requires/random2d")

/*
 * The main program
 */
void main() {
	// Calculate the effect relative strength
	float strength = u_mouse.x / u_resolution.x;

	// Shift the texture coordinates
	float i = floor(5.0 * strength * u_time);
	float f = fract(5.0 * strength * u_time);
	float vertical_offset = 0.01 * mix(random_1d(i), random_1d(i + 1.0), smoothstep(0.0, 1.0, f));
	float horizontal_offset = 0.005 * cos(200.0 * v_uv.y);
	vec2 uv = v_uv + strength * vec2(horizontal_offset, vertical_offset);

	// Get the original pixel color
	vec3 pixel_color = texture2D(u_texture, uv).rgb;

	// Add some white noise
	pixel_color += vec3(strength * random_2d(v_uv + 1.133001 * vec2(u_time, 0.0)));

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
