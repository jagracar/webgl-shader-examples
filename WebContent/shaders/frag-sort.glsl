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
 * Calculates the pixel resistance based on the pixel color
 */
float calculage_pixel_resistance(vec3 pixel_color) {
    return min(min(pixel_color.r, pixel_color.g), pixel_color.b);
}

/*
 * Calculates the pixel weight based on the pixel color
 */
float calculage_pixel_weight(vec3 pixel_color) {
    return dot(pixel_color, vec3(1.0, -1.0, -1.0));
}

/*
 * Swaps the current pixel color with the color bellow if the pixel bellow is
 * lighter
 */
vec3 swap_color_bellow(vec2 uv, float uv_min, float uv_max, float stop_value) {
    // Get the texture uv coordinates of the pixel bellow
    vec2 uv_bellow = uv + vec2(0.0, -1.0 / u_resolution.y);

    // Make sure we stay inside the texture block limits
    if (uv_bellow.y < uv_min || uv.y >= uv_max) {
        uv_bellow = uv;
    }

    // Get the pixel colors
    vec3 color = texture2D(u_texture, uv).rgb;
    vec3 color_bellow = texture2D(u_texture, uv_bellow).rgb;

    // Get the pixel resistances
    float resistance = calculage_pixel_resistance(color);
    float resistance_bellow = calculage_pixel_resistance(color_bellow);

    // Swap the colors only if the resistances are lower than the stop value
    if (resistance < stop_value && resistance_bellow < stop_value) {
        // Get the pixel weights
        float weight = calculage_pixel_weight(color);
        float weight_bellow = calculage_pixel_weight(color_bellow);

        // Swap the color if the pixel bellow is lighter
        if (weight > weight_bellow) {
            color = color_bellow;
        }
    }

    return color;
}

/*
 * Swaps the current pixel color with the color above if the pixel above is
 * heavier
 */
vec3 swap_color_above(vec2 uv, float uv_min, float uv_max, float stop_value) {
    // Get the texture uv coordinates of the pixel above
    vec2 uv_above = uv + vec2(0.0, 1.0 / u_resolution.y);

    // Make sure we stay inside the texture block limits
    if (uv.y < uv_min || uv_above.y >= uv_max) {
        uv_above = uv;
    }

    // Get the pixel colors
    vec3 color = texture2D(u_texture, uv).rgb;
    vec3 color_above = texture2D(u_texture, uv_above).rgb;

    // Get the pixel resistances
    float resistance = calculage_pixel_resistance(color);
    float resistance_above = calculage_pixel_resistance(color_above);

    // Swap the colors only if the resistances are lower than the stop value
    if (resistance < stop_value && resistance_above < stop_value) {
        // Get the pixel weights
        float weight = calculage_pixel_weight(color);
        float weight_above = calculage_pixel_weight(color_above);

        // Swap the color if the pixel above is heavier
        if (weight < weight_above) {
            color = color_above;
        }
    }

    return color;
}

/*
 * The main program
 */
void main() {
    // Set the sorting parameters using the mouse relative position
    float n_steps = floor(10.0 * u_mouse.y / u_resolution.y);
    float uv_min = floor(n_steps * v_uv.y) / n_steps;
    float uv_max = min(uv_min + 1.0 / n_steps, 1.0);
    float stop_value = u_mouse.x / u_resolution.x;

    // Check if we are in an even pixel row
    bool even_row = mod(floor(gl_FragCoord.y), 2.0) == 0.0;

    // Calculate the new pixel color
    vec3 pixel_color;

    if (mod(u_frame, 2.0) == 0.0) {
        if (even_row) {
            pixel_color = swap_color_bellow(v_uv, uv_min, uv_max, stop_value);
        } else {
            pixel_color = swap_color_above(v_uv, uv_min, uv_max, stop_value);
        }
    } else {
        if (even_row) {
            pixel_color = swap_color_above(v_uv, uv_min, uv_max, stop_value);
        } else {
            pixel_color = swap_color_bellow(v_uv, uv_min, uv_max, stop_value);
        }
    }

    // Fragment shader output
    gl_FragColor = vec4(pixel_color, 1.0);
}
