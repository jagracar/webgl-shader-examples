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
 * The main program
 */
void main() {
    // Calculate the pixel color based on the mouse position
    vec3 pixel_color;

    if (gl_FragCoord.x > u_mouse.x) {
        // Apply the gaussian kernel
        float step = 1.0 + 2.0 * u_mouse.y / u_resolution.y;
        pixel_color += (1.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-2, -2) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-2, -1) / u_resolution).rgb;
        pixel_color += (6.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-2, 0) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-2, 1) / u_resolution).rgb;
        pixel_color += (1.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-2, 2) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-1, -2) / u_resolution).rgb;
        pixel_color += (16.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-1, -1) / u_resolution).rgb;
        pixel_color += (24.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-1, 0) / u_resolution).rgb;
        pixel_color += (16.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-1, 1) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(-1, 2) / u_resolution).rgb;
        pixel_color += (6.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(0, -2) / u_resolution).rgb;
        pixel_color += (24.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(0, -1) / u_resolution).rgb;
        pixel_color += (36.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(0, 0) / u_resolution).rgb;
        pixel_color += (24.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(0, 1) / u_resolution).rgb;
        pixel_color += (6.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(0, 2) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(1, -2) / u_resolution).rgb;
        pixel_color += (16.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(1, -1) / u_resolution).rgb;
        pixel_color += (24.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(1, 0) / u_resolution).rgb;
        pixel_color += (16.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(1, 1) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(1, 2) / u_resolution).rgb;
        pixel_color += (1.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(2, -2) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(2, -1) / u_resolution).rgb;
        pixel_color += (6.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(2, 0) / u_resolution).rgb;
        pixel_color += (4.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(2, 1) / u_resolution).rgb;
        pixel_color += (1.0 / 256.0) * texture2D(u_texture, v_uv + step * vec2(2, 2) / u_resolution).rgb;
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
