uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//"import" our random function
#pragma glslify: random = require('glsl-random')

void main() {
	//quick pseudo-random 2D noise
	float n = random((gl_FragCoord.xy - u_mouse) / u_resolution.xy);
	gl_FragColor = vec4(vec3(n), 1.0);
}
