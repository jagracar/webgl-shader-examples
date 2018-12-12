#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")
#pragma glslify: noise = require("./requires/classicNoise2d")

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
        float noise_value = noise(vec2(r, 1.5 * angle));

        // Smooth the noise discontinuity between 0 and 360 degrees
        float smooth_step = radians(20.0);
        float limit_angle = radians(360.0) - smooth_step;

        if (angle > limit_angle) {
            noise_value = mix(noise_value, noise(vec2(r, 0.0)), (angle - limit_angle) / smooth_step);
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
