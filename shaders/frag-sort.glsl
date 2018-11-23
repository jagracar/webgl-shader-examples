#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")

/*
 * Calculates the pixel weight based on the pixel color
 */
float calculage_pixel_weight(vec3 pixel_color) {
    return dot(pixel_color, vec3(1.0, -1.0, -1.0));
}

/*
 * Swaps the current pixel color with pixel bellow if the pixel bellow is
 * lighter
 */
vec3 swap_color_bellow() {
    // Get the texture uv coordinates of the pixel bellow
    vec2 uv_bellow = v_uv + vec2(0.0, -1.0 / u_resolution.y);

    // Make sure we stay inside the texture dimensions
    uv_bellow.y = max(0.0, uv_bellow.y);

    // Get the pixel colors
    vec3 color = texture2D(u_texture, v_uv).rgb;
    vec3 color_bellow = texture2D(u_texture, uv_bellow).rgb;

    // Get the pixel weights
    float weight = calculage_pixel_weight(color);
    float weight_bellow = calculage_pixel_weight(color_bellow);

    // Swap the color if the pixel bellow is lighter
    if (weight > weight_bellow) {
        color = color_bellow;
    }

    return color;
}

/*
 * Swaps the current pixel color with pixel above if the pixel above is heavier
 */
vec3 swap_color_above() {
    // Get the texture uv coordinates of the pixel above
    vec2 uv_above = v_uv + vec2(0.0, 1.0 / u_resolution.y);

    // Make sure we stay inside the texture dimensions
    uv_above.y = min(uv_above.y, 1.0);

    // Get the pixel colors
    vec3 color = texture2D(u_texture, v_uv).rgb;
    vec3 color_above = texture2D(u_texture, uv_above).rgb;

    // Get the pixel weights
    float weight = calculage_pixel_weight(color);
    float weight_above = calculage_pixel_weight(color_above);

    // Swap the color if the pixel above is heavier
    if (weight < weight_above) {
        color = color_above;
    }

    return color;
}

/*
 * The main program
 */
void main() {
    // Check if we are in an even pixel row
    bool even_row = mod(floor(gl_FragCoord.y), 2.0) == 0.0;

    // Calculate the new pixel color
    vec3 pixel_color;

    if (mod(u_frame, 2.0) == 0.0) {
        pixel_color = even_row ? swap_color_bellow() : swap_color_above();
    } else {
        pixel_color = even_row ? swap_color_above() : swap_color_bellow();
    }

    // Fragment shader output
    gl_FragColor = vec4(pixel_color, 1.0);
}
