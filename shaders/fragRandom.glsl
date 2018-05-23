uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Import the random function
#pragma glslify: random = require("glsl-random")

void main() {
	float n = random((gl_FragCoord.xy - u_mouse) / u_resolution.xy);
	gl_FragColor = vec4(vec3(n), 1.0);
}
