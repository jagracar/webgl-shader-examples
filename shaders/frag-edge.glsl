#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")

/*
 * The main program
 */
void main() {
    // Calculate the pixel color based on the mouse position
    vec3 pixel_color;

    if (gl_FragCoord.x > u_mouse.x) {
        // Apply the edge detection kernel
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(-1, -1) / u_resolution).rgb;
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(-1, 0) / u_resolution).rgb;
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(-1, 1) / u_resolution).rgb;
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(0, -1) / u_resolution).rgb;
        pixel_color += 8.0 * texture2D(u_texture, v_uv + vec2(0, 0) / u_resolution).rgb;
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(0, 1) / u_resolution).rgb;
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(1, -1) / u_resolution).rgb;
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(1, 0) / u_resolution).rgb;
        pixel_color += -1.0 * texture2D(u_texture, v_uv + vec2(1, 1) / u_resolution).rgb;

        // Use the most extreme color value
        float min_value = min(pixel_color.r, min(pixel_color.g, pixel_color.b));
        float max_value = max(pixel_color.r, max(pixel_color.g, pixel_color.b));

        if (abs(min_value) > abs(max_value)) {
            pixel_color = vec3(min_value);
        } else {
            pixel_color = vec3(max_value);
        }

        // Rescale the pixel color using the mouse y position
        float scale = 0.2 + 2.5 * u_mouse.y / u_resolution.y;
        pixel_color = 0.5 + scale * pixel_color;
    } else if (gl_FragCoord.x > u_mouse.x - 1.0) {
        // Draw a line indicating the transition
        pixel_color = vec3(0.0);
    } else {
        // Use the original image pixel color
        pixel_color = texture2D(u_texture, v_uv).rgb;
    }

    // Fragment shader output
    gl_FragColor = vec4(pixel_color, 1.0);
}
