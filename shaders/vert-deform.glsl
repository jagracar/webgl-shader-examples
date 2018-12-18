#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")

/*
 * The main program
 */
void main() {
	// Calculate the new vertex position to simulate a wave effect
	float effect_intensity = 2.0 * u_mouse.x / u_resolution.x;
	vec3 new_position = position + effect_intensity * (0.5 + 0.5 * cos(position.x + 4.0 * u_time)) * normal;

	// Calculate the modelview position
	vec4 mv_position = modelViewMatrix * vec4(new_position, 1.0);

	// Save the varyings
	v_position = mv_position.xyz;
	v_normal = normalize(normalMatrix * normal);

	// Vertex shader output
	gl_Position = projectionMatrix * mv_position;
}
