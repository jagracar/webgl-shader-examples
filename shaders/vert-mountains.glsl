#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")
#pragma glslify: noise = require("./requires/classicNoise2d")

// The plane tile size, the flying speed and the maximum mountain height
uniform float u_tileSize;
uniform float u_speed;
uniform float u_maxHeight;

// Varying containing the terrain elevation
varying float v_elevation;

// Calculates the vertex displaced position
vec3 getDisplacedPosition(vec3 position) {
	// Calculate the total flying distance
	float distance = u_speed * u_time;

	// Calculate the vertex horizontal shift
	float h_shift = mod(distance, u_tileSize);

	// Calculate the vertex vertical shift
	float v_shift = u_maxHeight * noise(0.4 * floor(vec2(position.x, position.z - distance) / u_tileSize));

	// Flatten the bottom to simulate the lakes
	v_shift = max(-0.8 * u_maxHeight, v_shift);

	return position + vec3(0.0, v_shift, h_shift);
}

/*
 * The main program
 */
void main() {
	// Calculate the new vertex position
	vec3 new_position = getDisplacedPosition(position);

	// Calculate the modelview position
	vec4 mv_position = modelViewMatrix * vec4(new_position, 1.0);

	// Save the varyings
	v_position = mv_position.xyz;
	v_elevation = 0.5 * (u_maxHeight + new_position.y);

	// Vertex shader output
	gl_Position = projectionMatrix * mv_position;
}
