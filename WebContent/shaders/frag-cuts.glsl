#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

// Texture uniforms
uniform sampler2D u_texture;

// Texture varyings
varying vec2 v_uv;

/*
 * Returns a rotation matrix for the given angle
 */
mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

/*
 * The main program
 */
void main() {
    // Change the cuts pixel size as a function of the mouse relative position
    float cuts_size = 150.0 * (1.1 - u_mouse.x / u_resolution.x);

    // Calculate the cuts offset
    float angle = 0.4 * u_time;
    vec2 offset = 30.0 * sin(angle) * vec2(cos(angle), sin(angle));

    // Change the offset direction between cuts
    vec2 rotated_pos = rotate(angle) * (gl_FragCoord.xy - 0.5 * u_resolution) + 0.5 * u_resolution;
    offset *= 2.0 * floor(mod(rotated_pos.y / cuts_size, 2.0)) - 1.0;

    // Fragment shader output
    gl_FragColor = texture2D(u_texture, v_uv + offset / u_resolution);
}
