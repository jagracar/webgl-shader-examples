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
 * Returns a value between 1 and 0 that indicates if the pixel is inside the circle
 */
float circle(vec2 pixel, vec2 center, float radius) {
    return 1.0 - smoothstep(radius - 1.0, radius + 1.0, length(pixel - center));
}

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

    // Define the grid
    float grid_step = 12.0;
    vec2 grid_pos = mod(pos, grid_step);

    // Calculate the surface color
    float surface_color = 1.0;
    surface_color -= circle(grid_pos, vec2(grid_step / 2.0), 0.8 * grid_step * pow(1.0 - df, 2.0));
    surface_color = clamp(surface_color, 0.05, 1.0);

    // Fragment shader output
    gl_FragColor = vec4(vec3(surface_color), 1.0);
}
