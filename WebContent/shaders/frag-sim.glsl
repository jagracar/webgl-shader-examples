#define GLSLIFY 1
// Texture with the particle profile
uniform sampler2D u_texture;

/*
 * The main program
 */
void main() {
    // Get the particle alpha value from the texture
    float alpha = texture2D(u_texture, gl_PointCoord).a;

    // Fragment shader output
    gl_FragColor = vec4(vec3(1.0), alpha);
}
