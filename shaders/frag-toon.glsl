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
    float df = max(0.0, diffuseFactor(v_normal, light_direction));

    // Define the toon shading steps
    float nSteps = 4.0;
    float step = sqrt(df) * nSteps;
    step = (floor(step) + smoothstep(0.48, 0.52, fract(step))) / nSteps;

    // Calculate the surface color
    float surface_color = step * step;

    // Fragment shader output
    gl_FragColor = vec4(vec3(surface_color), 1.0);
}
