#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: square = require("./requires/shapes/square")
#pragma glslify: rectangle = require("./requires/shapes/rectangle")
#pragma glslify: circle = require("./requires/shapes/circle")
#pragma glslify: ellipse = require("./requires/shapes/ellipse")
#pragma glslify: lineSegment = require("./requires/shapes/lineSegment")
#pragma glslify: rotate = require("./requires/rotate2d")

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
