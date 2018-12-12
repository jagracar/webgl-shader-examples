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
    // Set the star radius
    float star_radius = 90.0;

    // Get the pixel position relative to the screen center
    vec2 position = gl_FragCoord.xy - 0.5 * u_resolution;

    // Calculate the pixel distance from the center
    float radial_distance = length(position);

    // Calculate the star color
    vec3 star_color = vec3(0.0);

    if (radial_distance < star_radius) {
        // Calculate the pixel polar angle
        float angle = atan(position.y, position.x) + radians(180.0);

        // Calculate the radial noise position
        float r = 0.05 * (radial_distance - u_frame);

        // Calculate the noise value
        float noise_value = cnoise(vec2(r, 1.5 * angle));

        // Smooth the noise discontinuity between 0 and 360 degrees
        float smooth_step = radians(20.0);
        float limit_angle = radians(360.0) - smooth_step;

        if (angle > limit_angle) {
            noise_value = mix(noise_value, cnoise(vec2(r, 0.0)), (angle - limit_angle) / smooth_step);
        }

        // The final star color is the combination of a radially constant
        // declining intensity plus the noise
        float f = pow(radial_distance / star_radius, 2.0);
        star_color = vec3((1.0 - f) + f * (0.1 + 0.4 * u_mouse.x / u_resolution.x) * (0.5 + 0.5 * noise_value));
    }

    // Calculate the average color of the pixels that are radially bellow the
    // current pixel
    vec3 average_color = vec3(0.0);
    float counter = 0.0;

    for (float i = -2.0; i <= 2.0; i++) {
        for (float j = -2.0; j <= 2.0; j++) {
            // Get the pixel color at the offset position
            vec2 offset = vec2(i, j);
            vec3 color = texture2D(u_texture, v_uv + offset / u_resolution).rgb;

            // Add the color to the average if the pixel is above the offset
            // position and is not a pixel inside the star
            if (radial_distance > length(position + offset) && radial_distance >= star_radius) {
                average_color += color;
                counter++;
            }
        }
    }

    if (counter > 0.0) {
        average_color /= counter;
    }

    // Set the distance decrement factor for the average color
    float decrement_factor = 0.1 * (u_resolution.y - u_mouse.y) / u_resolution.y;

    // Fragment shader output
    gl_FragColor = vec4(star_color + (1.0 - decrement_factor) * average_color, 1.0);
}
