#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")
#pragma glslify: noise = require("./requires/classicNoise2d")

// The sphere radius
uniform float u_radius;

// Varying containing the sphere elevation
varying float v_elevation;

// Calculates the vertex displaced position
vec3 getDisplacedPosition(vec3 position) {
	// Calculate the vertex shift
	float shift = 2.0
			* noise(vec2(3.0 * cos(atan(position.z, position.x)), 2.0 * u_time + 3.0 * acos(position.y / u_radius)));

	return position + normal * shift;
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
	v_elevation = length(new_position);

	// Vertex shader output
	gl_Position = projectionMatrix * mv_position;
}
