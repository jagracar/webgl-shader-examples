#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Common varyings
varying vec3 v_position;
varying vec3 v_normal;

/*
 * The main program
 */
void main() {
    // Fragment shader output
    gl_FragColor = vec4(0.5 + 0.5 * sin(10.0 * v_position).xyx, 1.0);
}
