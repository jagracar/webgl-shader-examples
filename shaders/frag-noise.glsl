#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: noise = require("./requires/classicNoise2d")

/*
 * Combines the 2d noise function at three different scales
 */
float multy_scale_noise(vec2 p) {
    return noise(3.0 * p) + noise(9.0 * p) + noise(20.0 * p);
}

/*
 * The main program
 */
void main() {
    // Normalize the pixel and mouse positions to the maximum scale dimension
    float max_dim = max(u_resolution.x, u_resolution.y);
    vec2 rel_pixel_pos = gl_FragCoord.xy / max_dim;
    vec2 rel_mouse_pos = u_mouse / max_dim;

    // Use a slightly shifted noise value for each color
    float r = multy_scale_noise(rel_pixel_pos + 0.05 * rel_mouse_pos);
    float g = multy_scale_noise(rel_pixel_pos + 0.05 * rel_mouse_pos.yx);
    float b = multy_scale_noise(rel_pixel_pos - 0.05 * rel_mouse_pos);

    // Fragment shader output
    gl_FragColor = vec4(vec3(r, g, b), 1.0);
}
