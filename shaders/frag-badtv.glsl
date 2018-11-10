#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")
#pragma glslify: noise1d = require("./requires/noise1d")
#pragma glslify: random2d = require("./requires/random2d")

/*
 * The main program
 */
void main() {
	// Calculate the effect relative strength
	float strength = (0.3 + 0.7 * noise1d(0.3 * u_time)) * u_mouse.x / u_resolution.x;

	// Calculate the effect jump at the current time interval
	float jump = 500.0 * floor(0.3 * (u_mouse.x / u_resolution.x) * (u_time + noise1d(u_time)));

	// Shift the texture coordinates
	vec2 uv = v_uv;
	uv.y += 0.2 * strength * (noise1d(5.0 * v_uv.y + 2.0 * u_time + jump) - 0.5);
	uv.x += 0.1 * strength * (noise1d(100.0 * strength * uv.y + 3.0 * u_time + jump) - 0.5);

	// Get the texture pixel color
	vec3 pixel_color = texture2D(u_texture, uv).rgb;

	// Add some white noise
	pixel_color += vec3(5.0 * strength * (random2d(v_uv + 1.133001 * vec2(u_time, 1.13)) - 0.5));

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
