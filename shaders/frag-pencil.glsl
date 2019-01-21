#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")
#pragma glslify: rotate = require("./requires/rotate2d")
#pragma glslify: diffuseFactor = require("./requires/diffuseFactor")
#pragma glslify: horizontalLine = require("./requires/shapes/horizontalLine")

/*
 * The main program
 */
void main() {
    // Use the mouse position to define the light direction
    float min_resolution = min(u_resolution.x, u_resolution.y);
    vec3 light_direction = -vec3((u_mouse - 0.5 * u_resolution) / min_resolution, 0.5);

    // Calculate the light diffusion factor
    float df = diffuseFactor(v_normal, light_direction);

    // Move the pixel coordinates origin to the center of the screen
    vec2 pos = gl_FragCoord.xy - 0.5 * u_resolution;

    // Rotate the coordinates 20 degrees
    pos = rotate(radians(20.0)) * pos;

    // Define the first group of pencil lines
    float line_width = 7.0 * (1.0 - smoothstep(0.0, 0.3, df)) + 0.5;
    float lines_sep = 16.0;
    vec2 grid_pos = vec2(pos.x, mod(pos.y, lines_sep));
    float line_1 = horizontalLine(grid_pos, lines_sep / 2.0, line_width);
    grid_pos.y = mod(pos.y + lines_sep / 2.0, lines_sep);
    float line_2 = horizontalLine(grid_pos, lines_sep / 2.0, line_width);

    // Rotate the coordinates 50 degrees
    pos = rotate(radians(-50.0)) * pos;

    // Define the second group of pencil lines
    lines_sep = 12.0;
    grid_pos = vec2(pos.x, mod(pos.y, lines_sep));
    float line_3 = horizontalLine(grid_pos, lines_sep / 2.0, line_width);
    grid_pos.y = mod(pos.y + lines_sep / 2.0, lines_sep);
    float line_4 = horizontalLine(grid_pos, lines_sep / 2.0, line_width);

    // Calculate the surface color
    float surface_color = 1.0;
    surface_color -= 0.8 * line_1 * (1.0 - smoothstep(0.5, 0.75, df));
    surface_color -= 0.8 * line_2 * (1.0 - smoothstep(0.4, 0.5, df));
    surface_color -= 0.8 * line_3 * (1.0 - smoothstep(0.4, 0.65, df));
    surface_color -= 0.8 * line_4 * (1.0 - smoothstep(0.2, 0.4, df));
    surface_color = clamp(surface_color, 0.05, 1.0);

    // Fragment shader output
    gl_FragColor = vec4(vec3(surface_color), 1.0);
}
