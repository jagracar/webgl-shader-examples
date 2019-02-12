#define GLSLIFY 1
// Texture with the particle profile
uniform sampler2D u_texture;

// Varying with the aggregation information
varying float v_aggregation;

/*
 * The main program
 */
void main() {
    // Use a different color for aggregated and non-aggregated particles
    vec3 particleColor = v_aggregation < 0.0 ? vec3(1.0) : vec3(0.5);

    // Fragment shader output
    gl_FragColor = vec4(particleColor, texture2D(u_texture, gl_PointCoord).a);
}
