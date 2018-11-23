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
 * The main program
 */
void main() {
	// Calculate the pixel color depending of the distance from the floor
	vec3 pixel_color = vec3(0.0);
	float floor = 2.0;

	if (gl_FragCoord.y <= floor) {
		// Use some 2D noise to simulate the fire change in position and time
		pixel_color.rg = vec2(cnoise(vec2(0.01 * gl_FragCoord.x, -0.2 * u_time)));
	} else {
		// Get a smoothed value of the pixels bellow
	    vec2 delta =  1.0 / u_resolution;
	    pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(2.0 * delta.x, -delta.y)).rgb;
		pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(1.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(0.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-1.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-2.0 * delta.x, -delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(2.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(1.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(0.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-1.0 * delta.x, -2.0 * delta.y)).rgb;
        pixel_color += 0.1 * texture2D(u_texture, v_uv + vec2(-2.0 * delta.x, -2.0 * delta.y)).rgb;

        // Decrease the intensity with the distance to the floor
        float fade_factor = 1.0 - smoothstep(0.0, u_resolution.x, (gl_FragCoord.y - floor) / 3.0);
        pixel_color.r *= fade_factor;
        pixel_color.g *= 0.99 * fade_factor;
        pixel_color.b = 0.0;
	}

	// Fragment shader output
	gl_FragColor = vec4(pixel_color, 1.0);
}
