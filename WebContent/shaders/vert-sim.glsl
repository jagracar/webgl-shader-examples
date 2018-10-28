#define GLSLIFY 1
// Particle index attribute
attribute float a_index;

// Simulation uniforms
uniform float u_width;
uniform float u_height;
uniform float u_particleSize;
uniform sampler2D u_positionTexture;

/*
 * The main program
 */
void main() {
    // Get the particle model view position
    vec2 uv = vec2((mod(a_index, u_width) + 0.5) / u_width, (floor(a_index / u_width) + 0.5) / u_height);
    vec4 mvPosition = modelViewMatrix * texture2D(u_positionTexture, uv);

    // Vertex shader output
    gl_PointSize = -u_particleSize / mvPosition.z;
    gl_Position = projectionMatrix * mvPosition;
}
