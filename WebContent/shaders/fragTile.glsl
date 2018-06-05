#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
    vec2 grid_pos = fract(gl_FragCoord.xy/100.0);

    gl_FragColor = vec4(vec3(grid_pos, 1.0), 1.0);
}
