#pragma glslify: import("./imports/uniforms2d.glsl")
#pragma glslify: random = require("glsl-random")

void main() {
	float max_dim = max(u_resolution.x, u_resolution.y);
	vec2 rel_pixel_pos = gl_FragCoord.xy / max_dim;
	vec2 p = floor(20.0 * rel_pixel_pos);

	gl_FragColor = vec4(vec3(random(p), random(20.0 * p), 1.0), 1.0);
}
