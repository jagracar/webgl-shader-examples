#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/textureUniforms.glsl")
#pragma glslify: import("./imports/textureVaryings.glsl")
#pragma glslify: laplacian = require("./requires/laplacian")

// Calculates the pixel color from the pixel chemical concentrations
vec4 calculate_color(vec2 concentrations) {
    return vec4(concentrations * vec2(0.05, 1.0), 0.0, 1.0);
}

// Calculates the pixel chemical concentrations from the pixel color
vec2 calculate_concentrations(vec4 color) {
    return color.rg / vec2(0.05, 1.0);
}

/*
 * The main program
 */
void main() {
    // Set the Gray-Scott reaction-diffusion simulation parameters
    float D_A = 0.8;
    float D_B = 0.4;
    float feed = 0.06 * v_uv.x;
    float kill = 0.035 + 0.03 * v_uv.x + (0.022 - 0.015 * v_uv.x) * v_uv.y;
    float dt = 1.0;

    // Calculate the chemical concentrations from the pixel color
    vec4 pixel_color = texture2D(u_texture, v_uv);
    vec2 concentrations = calculate_concentrations(pixel_color);
    float A = concentrations.x;
    float B = concentrations.y;

    // Calculate the laplacian
    vec2 lap = calculate_concentrations(laplacian(v_uv, u_texture, u_resolution));

    // Calculate the new chemical concentration values
    float dA = (D_A * lap.r - A * B * B + feed * (1.0 - A)) * dt;
    float dB = (D_B * lap.g + A * B * B - (kill + feed) * B) * dt;
    concentrations += vec2(dA, dB);

    // Modify the concentrations in the pixels under the mouse position
    if (length(gl_FragCoord.xy - u_mouse) < 5.0) {
        concentrations = vec2(0.0, 0.9);
    }

    // Fragment shader output
    gl_FragColor = calculate_color(concentrations);
}
