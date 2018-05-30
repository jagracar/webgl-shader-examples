#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: random = require("./requires/random2d")

void main() {
    float max_dim = max(u_resolution.x, u_resolution.y);
    vec2 p = floor(20.0 * gl_FragCoord.xy / max_dim);

    gl_FragColor = vec4(vec3(random(p), random(1.234 * p), 1.0), 1.0);
}
