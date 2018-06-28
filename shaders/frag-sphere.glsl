#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")
#pragma glslify: diffuse_factor = require("./requires/diffuseFactor")

/*
 * The main program
 */
void main() {
    // Use the mouse position to define the light direction
    float min_resolution = min(u_resolution.x, u_resolution.y);
    vec3 light_direction = -vec3((u_mouse - 0.5 * u_resolution) / min_resolution, 0.25);

    // Set the sphere surface color
    vec3 sphere_color = vec3(0.5 + 0.5 * cos(2.0 * v_position.y + 3.0 * u_time));

    // Apply the light diffusion factor
    sphere_color *= diffuse_factor(v_normal, light_direction);

    // Fragment shader output
    gl_FragColor = vec4(sphere_color, 1.0);
}
