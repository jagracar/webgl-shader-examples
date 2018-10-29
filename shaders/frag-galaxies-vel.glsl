// Simulation uniforms
uniform float u_dt;
uniform float u_mass;
uniform float u_haloSize;

// Simulation constants
const float width = resolution.x;
const float height = resolution.y;

// Softening factor. This is required to avoid high acceleration values
// when two particles get too close
const float softening = 0.001;

/*
 * The main program
 */
void main() {
    // Get the particle texture position
    vec2 uv = gl_FragCoord.xy / resolution;

    // Get the particle current position and velocity
    vec3 position = texture2D(u_positionTexture, uv).xyz;
    vec3 velocity = texture2D(u_velocityTexture, uv).xyz;

    // Loop over all the particles and calculate the total gravitational force
    vec3 totalForce = vec3(0.0);

    for (float i = 0.0; i < nGalaxies; i++) {
        // Get the position of the attracting particle
        vec2 particleUv = vec2(mod(i, width) + 0.5, floor(i / width) + 0.5) / resolution;
        vec3 particlePosition = texture2D(u_positionTexture, particleUv).xyz;

        // Calculate the force direction
        vec3 forceDirection = particlePosition - position;

        // Calculate the particle distance
        float distance = length(forceDirection);

        // Move to the next particle if the distance is exactly zero, which
        // indicates that we are comparing the particle with itself
        if (distance == 0.0) {
            continue;
        }

        // Add the particle gravitational force
        float massAtPosition = u_mass * min(distance, u_haloSize) / u_haloSize;
        totalForce += massAtPosition * (forceDirection / distance) / pow(distance + softening, 2.0);
    }

    // Return the updated particle velocity
    gl_FragColor = vec4(velocity + u_dt * totalForce, 1.0);
}
