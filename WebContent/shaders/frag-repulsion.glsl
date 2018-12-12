#define GLSLIFY 1
// Texture with the particle profile
uniform sampler2D u_texture;

// Particle color varying
varying vec3 v_color;

/*
 * The main program
 */
void main() {
    // Fragment shader output
    gl_FragColor = vec4(v_color, texture2D(u_texture, gl_PointCoord).a);
}
