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
 * Returns a rotation matrix for the given angle
 */
mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

/*
 *  Calculates the diffuse factor produced by the light illumination
 */
float diffuseFactor(vec3 normal, vec3 light_direction) {
    float df = dot(normalize(normal), normalize(light_direction));

    if (gl_FrontFacing) {
        df = -df;
    }

    return max(0.0, df);
}

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the horizontal line
 */
float horizontalLine(vec2 pixel, float y_pos, float width) {
    return 1.0 - smoothstep(-1.0, 1.0, abs(pixel.y - y_pos) - 0.5 * width);
}

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
