uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//"import" our 2d noise function
#pragma glslify: noise = require('glsl-noise/classic/2d')

void main() {
	//quick pseudo-random 2D noise
	float n = noise(10.0 * (gl_FragCoord.xy - u_mouse) / u_resolution.xy);
	gl_FragColor = vec4(vec3(n), 1.0);
}
