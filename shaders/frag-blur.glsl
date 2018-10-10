#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")
#pragma glslify: kernel = require("./requires/kernels/gaussianKernel")

/*
 * The main program
 */
void main() {
    // Calculate the pixel color based on the mouse position
    vec3 pixel_color;

    if (gl_FragCoord.x > u_mouse.x) {
        // Apply the gaussian kernel
        float step = 1.0 + 4.0 * u_mouse.y / u_resolution.y;

        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                pixel_color += kernel[i][j] * texture2D(u_texture, v_uv + step * vec2(i - 1, j - 1) / u_resolution).rgb;
            }
        }
    } else {
        // Use the original image pixel color
        pixel_color = texture2D(u_texture, v_uv).rgb;
    }

    // Fragment shader output
    gl_FragColor = vec4(pixel_color, 1.0);
}
