#pragma glslify: import("./imports/commonUniforms.glsl")

void main() {
    vec2 grid_pos = fract(gl_FragCoord.xy/100.0);

    gl_FragColor = vec4(vec3(grid_pos, 1.0), 1.0);
}
