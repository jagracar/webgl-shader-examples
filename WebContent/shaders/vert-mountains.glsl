#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

// Common varyings
varying vec3 v_position;
varying vec3 v_normal;

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

// The plane tile size, the flying speed and the maximum mountain height
uniform float u_tileSize;
uniform float u_speed;
uniform float u_maxHeight;

// Varying containing the terrain elevation
varying float v_elevation;

// Calculates the vertex displaced position
vec3 getDisplacedPosition(vec3 position) {
	// Calculate the total flying distance
	float distance = u_speed * u_time;

	// Calculate the vertex horizontal shift
	float h_shift = mod(distance, u_tileSize);

	// Calculate the vertex vertical shift
	float v_shift = u_maxHeight * cnoise(0.4 * floor(vec2(position.x, position.z - distance) / u_tileSize));

	// Flatten the bottom to simulate the lakes
	v_shift = max(-0.8 * u_maxHeight, v_shift);

	return position + vec3(0.0, v_shift, h_shift);
}

/*
 * The main program
 */
void main() {
	// Calculate the new vertex position
	vec3 new_position = getDisplacedPosition(position);

	// Calculate the modelview position
	vec4 mv_position = modelViewMatrix * vec4(new_position, 1.0);

	// Save the varyings
	v_position = mv_position.xyz;
	v_elevation = 0.5 * (u_maxHeight + new_position.y);

	// Vertex shader output
	gl_Position = projectionMatrix * mv_position;
}
