#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

// Texture uniforms
uniform sampler2D u_texture;

// Texture varyings
varying vec2 v_uv;

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the circle
 */
float circle(vec2 pixel, vec2 center, float radius) {
    return 1.0 - smoothstep(radius - 1.0, radius + 1.0, length(pixel - center));
}

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
