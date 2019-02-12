#define GLSLIFY 1
// Particle index attribute
attribute float a_index;

// Simulation uniforms
uniform float u_width;
uniform float u_height;
uniform float u_particleSize;
uniform sampler2D u_positionTexture;

// Varying with the aggregation information
varying float v_aggregation;

/*
 * The main program
 */
void main() {
    // Get the particle model view position
    vec2 uv = vec2((mod(a_index, u_width) + 0.5) / u_width, (floor(a_index / u_width) + 0.5) / u_height);
    vec4 position = texture2D(u_positionTexture, uv);
    vec4 mvPosition = modelViewMatrix * vec4(position.xyz, 1.0);

    // Pass the aggregation information to the fragment shader
    v_aggregation = position.w;

    // Vertex shader output
    gl_PointSize = v_aggregation < 0.0 ? -u_particleSize / mvPosition.z : -0.5 * u_particleSize / mvPosition.z;
    gl_Position = projectionMatrix * mvPosition;
}
