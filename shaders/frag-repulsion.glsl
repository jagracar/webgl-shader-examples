// Texture with the particle profile
uniform sampler2D u_texture;

// Particle color varying
varying vec3 v_color;

/*
 * The main program
 */
void main() {
    // Get the particle alpha value from the texture
    float alpha = texture2D(u_texture, gl_PointCoord).a;

    // Fragment shader output
    gl_FragColor = vec4(v_color, smoothstep(0.05, 0.1, alpha));
}
