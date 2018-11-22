#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")
#pragma glslify: noise = require("./requires/classicNoise2d")

/*
 * The main program
 */
void main() {
	// Calculate the pixel color depending of the distance from the floor
	vec3 pixel_color = vec3(0.0);
	float floor = 2.0;

	if (gl_FragCoord.y <= floor) {
		// Use some 2D noise to simulate the fire change in position and time
		pixel_color.rg = vec2(noise(vec2(0.01 * gl_FragCoord.x, -0.2 * u_time)));
	} else {
		// Get a smoothed value of the pixels bellow
	    vec2 delta =  1.0 / u_resolution;
	    pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(2.0 * delta.x, -delta.y)).rgb;
		pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(1.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(0.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-1.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-2.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(2.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(1.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(0.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-1.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-2.0 * delta.x, -2.0 * delta.y)).rgb;

        // Decrease the intensity with the distance to the floor
        float fade_factor = 1.0 - smoothstep(0.0, u_resolution.x, (gl_FragCoord.y - floor) / 3.0);
        pixel_color.r *= fade_factor;
        pixel_color.g *= 0.99 * fade_factor;
        pixel_color.b = 0.0;
	}

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
