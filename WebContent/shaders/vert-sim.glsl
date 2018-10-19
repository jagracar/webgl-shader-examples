#define GLSLIFY 1
// The particle reference uv texture position
attribute vec2 reference;

// Texture with the particles current positions
uniform sampler2D u_positionTexture;

// The particle size
uniform float u_size;

/*
 * The main program
 */
void main() {
    // Get the particle model view position
    vec4 mvPosition = modelViewMatrix * texture2D(u_positionTexture, reference);

    // Vertex shader output
    gl_PointSize = -u_size / mvPosition.z;
    gl_Position = projectionMatrix * mvPosition;
}
