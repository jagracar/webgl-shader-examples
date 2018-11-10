#pragma glslify: random1d = require("./random1d")

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

#pragma glslify: export(noise1d)
