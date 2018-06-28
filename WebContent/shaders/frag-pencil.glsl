#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

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
float diffuse_factor_1604150559(vec3 normal, vec3 light_direction) {
    return -dot(normalize(normal), normalize(light_direction));
}

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the horizontal line
 */
float horizontal_line_1117569599(vec2 pixel, float y_pos, float width) {
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
    float df = max(0.0, diffuse_factor_1604150559(v_normal, light_direction));

    // Move the pixel coordinates origin to the center of the screen
    vec2 pos = gl_FragCoord.xy - 0.5 * u_resolution;

    // Rotate the coordinates by the light direction angle
    pos = rotate(atan(light_direction.y / light_direction.x)) * pos;

    // Define the first group of pencil lines
    float line_width = 1.0;
    float lines_sep = 16.0;
    vec2 line_pos = vec2(pos.x, mod(pos.y, lines_sep));
    float line_1_col = 0.8 * horizontal_line_1117569599(line_pos, lines_sep / 2.0, line_width);
    line_pos.y = mod(pos.y + lines_sep / 2.0, lines_sep);
    float line_2_col = 0.8 * horizontal_line_1117569599(line_pos, lines_sep / 2.0, line_width);

    // Rotate the coordinates 50 degrees
    pos = rotate(radians(-50.0)) * pos;

    // Define the second group of pencil lines
    lines_sep = 12.0;
    line_pos = vec2(pos.x, mod(pos.y, lines_sep));
    float line_3_col = 0.8 * horizontal_line_1117569599(line_pos, lines_sep / 2.0, line_width);
    line_pos.y = mod(pos.y + lines_sep / 2.0, lines_sep);
    float line_4_col = 0.8 * horizontal_line_1117569599(line_pos, lines_sep / 2.0, line_width);

    // Calculate the sphere color
    vec3 sphere_color = vec3(1.0);
    sphere_color -= line_1_col * (1.0 - smoothstep(0.5, 0.95, df));
    sphere_color -= line_2_col * (1.0 - smoothstep(0.4, 0.6, df));
    sphere_color -= line_3_col * (1.0 - smoothstep(0.4, 0.8, df));
    sphere_color -= line_4_col * (1.0 - smoothstep(0.2, 0.3, df));

    // Fragment shader output
    gl_FragColor = vec4(sphere_color, 1.0);
}
