#define GLSLIFY 1
// Texture with the particle profile
uniform sampler2D u_texture;

/*
 * The main program
 */
void main() {
    // Fragment shader output
    gl_FragColor =texture2D(u_texture, gl_PointCoord);
}
