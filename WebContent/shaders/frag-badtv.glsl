#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Texture uniforms
uniform sampler2D u_texture;

// Texture varyings
varying vec2 v_uv;

/*
 * Random number generator with a float seed
 *
 * Credits:
 * http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0
 */
highp float random_0(float dt) {
    highp float c = 43758.5453;
    highp float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

/*
 * Random number generator with a vec2 seed
 *
 * Credits:
 * http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0
 * https://github.com/mattdesl/glsl-random
 */
highp float random_1(vec2 co) {
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt = dot(co.xy, vec2(a, b));
    highp float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

/*
 * The main program
 */
void main() {
	// Calculate the effect relative strength
	float strength = u_mouse.x / u_resolution.x;

	// Shift the texture coordinates
	float i = floor(5.0 * strength * u_time);
	float f = fract(5.0 * strength * u_time);
	float vertical_offset = 0.01 * mix(random_0(i), random_0(i + 1.0), smoothstep(0.0, 1.0, f));
	float horizontal_offset = 0.005 * cos(200.0 * v_uv.y);
	vec2 uv = v_uv + strength * vec2(horizontal_offset, vertical_offset);

	// Get the original pixel color
	vec3 pixel_color = texture2D(u_texture, uv).rgb;

	// Add some white noise
	pixel_color += vec3(strength * random_1(v_uv + 1.133001 * vec2(u_time, 0.0)));

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
