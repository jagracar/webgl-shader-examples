#define GLSLIFY 1
// Texture varyings
varying vec2 v_uv;

/*
 * The main program
 */
void main() {
    // Calculate the varyings
    v_uv = uv;

    // Vertex shader output
    gl_Position = vec4(position, 1.0);
}
