#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: noise = require("./requires/classicNoise2d")

float multy_scale_noise(vec2 p) {
    return noise(3.0 * p) + noise(9.0 * p) + noise(20.0 * p);
}

void main() {
    float max_dim = max(u_resolution.x, u_resolution.y);
    vec2 rel_pixel_pos = gl_FragCoord.xy / max_dim;
    vec2 rel_mouse_pos = u_mouse / max_dim;

    float r = multy_scale_noise(rel_pixel_pos + 0.05 * rel_mouse_pos);
    float g = multy_scale_noise(rel_pixel_pos + 0.05 * rel_mouse_pos.yx);
    float b = multy_scale_noise(rel_pixel_pos - 0.05 * rel_mouse_pos);

    gl_FragColor = vec4(vec3(r, g, b), 1.0);
}
