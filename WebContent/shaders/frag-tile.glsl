#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the square
 */
float square(vec2 pixel, vec2 bottom_left, float side) {
    vec2 top_right = bottom_left + side;

    return smoothstep(-1.0, 1.0, pixel.x - bottom_left.x) * smoothstep(-1.0, 1.0, pixel.y - bottom_left.y)
            * smoothstep(-1.0, 1.0, top_right.x - pixel.x) * smoothstep(-1.0, 1.0, top_right.y - pixel.y);
}

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the rectangle
 */
float rectangle(vec2 pixel, vec2 bottom_left, vec2 sides) {
    vec2 top_right = bottom_left + sides;

    return smoothstep(-1.0, 1.0, pixel.x - bottom_left.x) * smoothstep(-1.0, 1.0, pixel.y - bottom_left.y)
            * smoothstep(-1.0, 1.0, top_right.x - pixel.x) * smoothstep(-1.0, 1.0, top_right.y - pixel.y);
}

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the circle
 */
float circle(vec2 pixel, vec2 center, float radius) {
    return 1.0 - smoothstep(radius - 1.0, radius + 1.0, length(pixel - center));
}

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the ellipse
 */
float ellipse(vec2 pixel, vec2 center, vec2 radii) {
    vec2 relative_pos = pixel - center;
    float dist = length(relative_pos);
    float r = radii.x * radii.y * dist / length(radii.yx * relative_pos);

    return 1.0 - smoothstep(r - 1.0, r + 1.0, dist);
}

/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the line segment
 */
float lineSegment(vec2 pixel, vec2 start, vec2 end, float width) {
    vec2 pixel_dir = pixel - start;
    vec2 line_dir = end - start;
    float line_length = length(line_dir);
    float projected_dist = dot(pixel_dir, line_dir) / line_length;
    float tanjential_dist = sqrt(dot(pixel_dir, pixel_dir) - projected_dist * projected_dist);

    return smoothstep(-1.0, 1.0, projected_dist) * smoothstep(-1.0, 1.0, line_length - projected_dist)
            * (1.0 - smoothstep(-1.0, 1.0, tanjential_dist - 0.5 * width));
}

/*
 * Returns a rotation matrix for the given angle
 */
mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

/*
 * The main program
 */
void main() {
    // Set the background color
    vec3 pixel_color = vec3(0.0);

    // Divide the screen in a grid
    vec2 grid1_pos = mod(gl_FragCoord.xy, 250.0);

    // Add a blue square to each grid element
    pixel_color = mix(pixel_color, vec3(0.3, 0.4, 1.0), square(grid1_pos, vec2(5.0, 5.0), 150.0));

    // Add a red circle to each grid element
    pixel_color = mix(pixel_color, vec3(1.0, 0.4, 0.3), circle(grid1_pos, vec2(0.0, 0.0), 80.0));

    // Add ten grey lines to each grid element
    for (float i = 0.0; i < 10.0; ++i) {
        pixel_color = mix(pixel_color, vec3(0.8),
                lineSegment(grid1_pos, vec2(10.0, -10.0 * i), vec2(150.0, 100.0 - 10.0 * i), 4.0));
    }

    // Apply some rotations to the grid
    grid1_pos -= 100.0;
    grid1_pos = rotate(u_time) * grid1_pos;
    grid1_pos += 100.0;
    grid1_pos -= 60.0;
    grid1_pos = rotate(0.66 * u_time) * grid1_pos;
    grid1_pos += 60.0;

    // Draw a green rectangle to each grid element
    pixel_color = mix(pixel_color, vec3(0.3, 0.9, 0.3), rectangle(grid1_pos, vec2(60.0, 50.0), vec2(40.0, 20)));

    // Define a second rotated grid
    vec2 grid2_pos = mod(rotate(radians(45.0)) * gl_FragCoord.xy, 100.0);

    // Add a white circle to each grid element
    pixel_color = mix(pixel_color, vec3(1.0), circle(grid2_pos, vec2(50.0, 50.0), 20.0));

    // Fragment shader output
    gl_FragColor = vec4(pixel_color, 1.0);
}
