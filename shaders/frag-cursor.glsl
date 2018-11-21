#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")
#pragma glslify: circle = require("./requires/shapes/circle")

/*
 * The main program
 */
void main() {
    // Get the pixel color
    vec3 pixel_color = texture2D(u_texture, v_uv).rgb;

	// Draw a circle at the mouse position
    float circle_radius = 50.0;
    vec3 circle_color = vec3(0.5, 0.5, 0.8) + vec3(0.3 * cos(u_time), 0.3 * sin(1.3 *u_time), 0.2 * cos(2.7 *u_time));
    float mix_factor = 0.8 * circle(gl_FragCoord.xy, u_mouse, circle_radius);
    pixel_color = mix(pixel_color, circle_color, mix_factor);

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
