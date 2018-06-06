#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: square = require("./requires/square")
#pragma glslify: rectangle = require("./requires/rectangle")
#pragma glslify: circle = require("./requires/circle")
#pragma glslify: ellipse = require("./requires/ellipse")
#pragma glslify: line = require("./requires/line")
#pragma glslify: rotate = require("./requires/rotate2d")

void main() {
    vec2 grid_pos = mod(gl_FragCoord.xy, 250.0);

    vec3 pixel_color = mix(vec3(0.0), vec3(0.3, 0.4, 1.0), square(grid_pos, vec2(5.0, 5.0), 150.0));
    pixel_color = mix(pixel_color, vec3(1.0, 0.4, 0.3), circle(grid_pos, vec2(-10.0, 20.0), 40.0));

    for (float i = 0.0; i < 10.0; ++i) {
        pixel_color = mix(pixel_color, vec3(0.8, 0.8, 0.8),
                line(grid_pos, vec2(10.0, -10.0 * i), vec2(150.0, 100.0 - 10.0 * i), 2.0));
    }

    grid_pos = mod(rotate(radians(45.0)) * gl_FragCoord.xy, 100.0);
    pixel_color = mix(pixel_color, vec3(1.0, 1.0, 1.0), circle(grid_pos, vec2(50.0), 20.0));

    grid_pos = mod(gl_FragCoord.xy, 100.0);
    grid_pos -= 50.0;
    grid_pos = rotate(u_time) * grid_pos;
    grid_pos += 50.0;
    pixel_color = mix(pixel_color, vec3(0.3, 1.0, 0.4), ellipse(grid_pos, vec2(50.0, 50.0), vec2(30.0, 10.0)));
    grid_pos = rotate(u_time) * grid_pos;
    pixel_color = mix(pixel_color, vec3(1.0, 0.2, 1.0), rectangle(grid_pos, vec2(10.0, 10.0), vec2(40.0, 20)));

    gl_FragColor = vec4(pixel_color, 1.0);
}
