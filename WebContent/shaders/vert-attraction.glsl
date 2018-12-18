#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

// Common varyings
varying vec3 v_position;
varying vec3 v_normal;

/*
 * The main program
 */
void main() {
	// Define the attractor position using spherical coordinates
	float r = 15.0;
	float theta = 0.87 * u_time;
	float phi = 0.63 * u_time;
	vec3 attractor_position = r * vec3(sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta));

	// Calculate the new vertex position to simulate attraction effect
	vec3 effect_direction = attractor_position - position;
	float effect_intensity = min(30.0 * pow(length(effect_direction), -2.0), 1.0);
	vec3 new_position = position + effect_intensity * effect_direction;

	// Calculate the modelview position
	vec4 mv_position = modelViewMatrix * vec4(new_position, 1.0);

	// Save the varyings
	v_position = mv_position.xyz;
	v_normal = normalize(normalMatrix * normal);

	// Vertex shader output
	gl_Position = projectionMatrix * mv_position;
}
