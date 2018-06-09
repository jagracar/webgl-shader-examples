#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")

/*
 * The main program
 */
void main() {
    // Fragment shader output
    gl_FragColor = vec4(0.5 + 0.5 * sin(10.0 * v_position).xyx, 1.0);
}
