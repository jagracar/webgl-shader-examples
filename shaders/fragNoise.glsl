uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Import the 2d noise function
#pragma glslify: noise = require("glsl-noise/classic/2d")

void main() {
	float n = noise(5.0 * (gl_FragCoord.xy - u_mouse) / u_resolution.xy);
	gl_FragColor = vec4(vec3(n), 1.0);
}
