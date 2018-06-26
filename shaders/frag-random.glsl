#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: random = require("./requires/random2d")

/*
 * The main program
 */
void main() {
    // Create a grid of squares that depends on the mouse position
    vec2 square = floor((gl_FragCoord.xy - u_mouse) / 30.0);

    // Give a random color to each square
    vec3 square_color = vec3(random(square), random(1.234 * square), 1.0);

    // Fragment shader output
    gl_FragColor = vec4(square_color, 1.0);
}
