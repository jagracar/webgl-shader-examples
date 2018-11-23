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
 * Random number generator with a float seed
 *
 * Credits:
 * http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0
 */
highp float random1d(float dt) {
    highp float c = 43758.5453;
    highp float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

/*
 * Pseudo-noise generator
 *
 * Credits:
 * https://thebookofshaders.com/11/
 */
highp float noise1d(float value) {
	highp float i = floor(value);
	highp float f = fract(value);
	return mix(random1d(i), random1d(i + 1.0), smoothstep(0.0, 1.0, f));
}

/*
 * Random number generator with a vec2 seed
 *
 * Credits:
 * http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0
 * https://github.com/mattdesl/glsl-random
 */
highp float random2d(vec2 co) {
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
