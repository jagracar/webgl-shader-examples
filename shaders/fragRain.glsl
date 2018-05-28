#pragma glslify: import("./imports/uniforms2d.glsl")
#pragma glslify: random = require("glsl-random")

/*
 *  Returns a random drop position for the given seed value 
 */
vec2 random_drop_pos(float val) {
	return vec2(-0.5 + 1.5 * random(vec2(val)), 1.0) * u_resolution;
}

/*
 * Calculates the drop color at the given pixel position
 */
vec3 draw_drop(vec2 pixel, vec2 pos, vec2 velocity_dir, float radius, float size) {
	vec2 pixel_dir = pixel - pos;
	float projected_dist = dot(pixel_dir, -velocity_dir);
	float tanjential_dist_sq = dot(pixel_dir, pixel_dir) - pow(projected_dist, 2.0);
	float radius_sq = pow(radius, 2.0);

	return vec3(
			step(0.0, projected_dist) * (1.0 - smoothstep(size / 5.0, size, projected_dist))
					* (1.0 - smoothstep(radius_sq / 2.0, radius_sq, tanjential_dist_sq)));
}

void main() {
	// Set the total number of rain drops that are visible at a given time
	const float n_drops = 20.0;

	// Set the drop radius
	float radius = 2.0;

	// Set the drop size
	float size = 30.0;

	// Set the drop velocity in pixels per second
	vec2 velocity = vec2(0.12, -0.4) * u_resolution.y;
	vec2 velocity_dir = normalize(velocity);

	// Set the drop fall time in seconds
	float fall_time = 2.0;

	// Iterate over the drops to calculate the total drop color
	vec3 drop_color = vec3(0.0);

	for (float i = 0.0; i < n_drops; i++) {
		// Offset the running time for each drop
		float time = u_time + fall_time * (i + i / n_drops);

		// Calculate the time since the drop appeared on the screen
		float ellapsed_time = mod(time, fall_time);

		// Calculate the drop initial position
		vec2 initial_pos = random_drop_pos(i + floor(time / fall_time - i) * n_drops);

		// Calculate the drop current position
		vec2 pos = initial_pos + ellapsed_time * velocity;

		// Add the drop to the total drop color
		drop_color += draw_drop(gl_FragCoord.xy, pos, velocity_dir, radius, size);
	}

	// Calculate the background color
	vec3 bg_color = vec3(0.0, 0.0, smoothstep(0.4, 1.8, 1.0 - gl_FragCoord.y / u_resolution.y));

	// Add the two colors together
	gl_FragColor = vec4(drop_color + bg_color, 1.0);
}
