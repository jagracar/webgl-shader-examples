#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")
#pragma glslify: diffuseFactor = require("./requires/diffuseFactor")

/*
 * The main program
 */
void main() {
    // Use the mouse position to define the light direction
    float min_resolution = min(u_resolution.x, u_resolution.y);
    vec3 light_direction = -vec3((u_mouse - 0.5 * u_resolution) / min_resolution, 0.5);

    // Calculate the light diffusion factor
    float df = diffuseFactor(v_normal, light_direction);

    // Calculate the surface color
    float surface_color = df;

    // Don't paint the pixels between the stripes
    if (cos(2.0 * v_position.y + 3.0 * u_time) < 0.0) {
        discard;
    }

    // Fragment shader output
    gl_FragColor = vec4(vec3(surface_color), 1.0);
}
