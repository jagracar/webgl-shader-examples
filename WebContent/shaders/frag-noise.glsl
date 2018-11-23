#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

/*
 * GLSL textureless classic 2D noise "cnoise",
 * with an RSL-style periodic variant "pnoise".
 * Author:  Stefan Gustavson (stefan.gustavson@liu.se)
 * Version: 2011-08-22
 *
 * Many thanks to Ian McEwan of Ashima Arts for the
 * ideas for permutation and gradient selection.
 *
 * Copyright (c) 2011 Stefan Gustavson. All rights reserved.
 * Distributed under the MIT license. See LICENSE file.
 * https://github.com/stegu/webgl-noise
 */

vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}

vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}

vec2 fade(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float cnoise(vec2 P) {
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi);
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;

    vec4 i = permute(permute(ix) + iy);

    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0;
    vec4 gy = abs(gx) - 0.5;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;

    vec2 g00 = vec2(gx.x, gy.x);
    vec2 g10 = vec2(gx.y, gy.y);
    vec2 g01 = vec2(gx.z, gy.z);
    vec2 g11 = vec2(gx.w, gy.w);

    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;

    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));

    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

/*
 * Combines the 2d noise function at three different scales
 */
float multy_scale_noise(vec2 p, vec2 rel_mouse_pos) {
    return 0.8 * cnoise(5.0 * p) + rel_mouse_pos.x * cnoise(15.0 * p) + rel_mouse_pos.y * cnoise(60.0 * p);
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
    float r = multy_scale_noise(rel_pixel_pos + 0.05 * rel_mouse_pos, rel_mouse_pos);
    float g = multy_scale_noise(rel_pixel_pos + 0.05 * rel_mouse_pos.yx, rel_mouse_pos);
    float b = multy_scale_noise(rel_pixel_pos - 0.05 * rel_mouse_pos, rel_mouse_pos);

    // Fragment shader output
    gl_FragColor = vec4(vec3(r, g, b), 1.0);
}
