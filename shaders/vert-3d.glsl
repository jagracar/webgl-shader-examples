#pragma glslify: import("./imports/commonVaryings3d.glsl")

/*
 * The main program
 */
void main() {
    // Save the varyings
    v_position = position;
    v_normal = normalize(normalMatrix * normal);

    // Vertex shader output
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
