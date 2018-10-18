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
    // Get the particle new position
    vec3 newPosition = texture2D(u_positionTexture, reference).xyz;

    // Vertex shader output
    gl_PointSize = u_size;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
}
