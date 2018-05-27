#pragma glslify: import("./imports/uniforms2d.glsl")
#pragma glslify: random = require("glsl-random")

vec2 random_point(float val) {
	return vec2(-0.5 + 1.5 * random(vec2(val)), 1.0) * u_resolution;
}

void main() {
	const int n_points = 40;
	const float fall_time = 3.0;
	vec2 speed = vec2(1.0, -2.5) * 0.12 * u_resolution.y;

	for (int i = 0; i < n_points; i++) {
		float time = u_time / fall_time + float(i) + float(i) / float(n_points);
		float ellapsed_time = fract(time);
		vec2 p = random_point(
				float(i) + floor(time - float(i)) * float(n_points));

		if (length(gl_FragCoord.xy - (p + fall_time * ellapsed_time * speed))
				< 30.0) {
			gl_FragColor = vec4(1.0);
			return;
		}
	}

	gl_FragColor = vec4(vec3(0.0), 1.0);
}
