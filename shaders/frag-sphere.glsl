#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")

/*
 *  Calculates the diffuse factor produced by the light illumination
 */
float diffuse_factor(vec3 light_direction) {
    return dot(normalize(v_normal), normalize(light_direction));
}

/*
 * The main program
 */
void main() {
    // Use the mouse position to define the light direction
    vec3 light_direction = vec3(5.0 * (u_mouse / u_resolution - 0.5), 1.0);

    // Set the sphere surface color
    vec3 sphere_color = vec3(0.5 + 0.5 * cos(2.0 * v_position.y + 3.0 * u_time));

    // Apply the light diffusion factor
    sphere_color *= diffuse_factor(light_direction);

    // Fragment shader output
    gl_FragColor = vec4(sphere_color, 1.0);
}
