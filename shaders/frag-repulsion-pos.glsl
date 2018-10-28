// Simulation uniforms
uniform float u_dt;
uniform float u_nActiveParticles;

// Simulation constants
const float width = resolution.x;

/*
 * The main program
 */
void main() {
    // Get the particle texture position
    vec2 uv = gl_FragCoord.xy / resolution;

    // Get the particle current position and velocity
    vec3 position = texture2D(u_positionTexture, uv).xyz;
    vec3 velocity = texture2D(u_velocityTexture, uv).xyz;

    // Check if the particle is one of the active particles
    if ((gl_FragCoord.x - 0.5) + (gl_FragCoord.y - 0.5) * width < u_nActiveParticles) {
        // Return the updated particle position
        gl_FragColor = vec4(position + u_dt * velocity, 1.0);
    } else {
        // Return the original particle position
        gl_FragColor = vec4(position, 1.0);
    }
}
