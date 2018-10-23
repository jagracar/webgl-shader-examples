#define GLSLIFY 1
// Simulation uniforms
uniform float u_dt;

/*
 * The main program
 */
void main() {
    // Get the particle texture position
    vec2 uv = gl_FragCoord.xy / resolution;

    // Get the particle current position and velocity
    vec3 position = texture2D(u_positionTexture, uv).xyz;
    vec3 velocity = texture2D(u_velocityTexture, uv).xyz;

    // Return the updated particle position
    gl_FragColor = vec4(position + u_dt * velocity, 1.0);
}
