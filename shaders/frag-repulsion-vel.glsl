// Simulation uniforms
uniform float u_dt;
uniform float u_nActiveParticles;

// Simulation constants
const float width = resolution.x;
const float height = resolution.y;
const float nParticles = width * height;

// Softening factor. This is required to avoid high acceleration values
// when two particles get too close
const float softening = 0.005;

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
        // Loop over all the particles and calculate the total repulsion force
        vec3 totalForce = vec3(0.0);
        float forceScalingFactor = 0.0001;

        for (float i = 0.0; i < nParticles; i++) {
            // Consider only active particles
            if (i >= u_nActiveParticles) {
                break;
            }

            // Get the position of the repulsing particle
            vec2 particleUv = vec2(mod(i, width) + 0.5, floor(i / width) + 0.5) / resolution;
            vec3 particlePosition = texture2D(u_positionTexture, particleUv).xyz;

            // Calculate the force direction
            vec3 forceDirection = -(particlePosition - position);

            // Calculate the particle distance
            float distance = length(forceDirection);

            // Move to the next particle if the distance is exactly zero, which
            // indicates that we are comparing the particle with itself
            if (distance == 0.0) {
                continue;
            }

            // Add the particle repulsion force
            float distanceDumping = 1.0 - smoothstep(0.45, 0.5, distance);
            totalForce += forceScalingFactor * distanceDumping * (forceDirection / distance)
                    / pow(distance + softening, 2.0);
        }

        // Return the updated particle velocity
        gl_FragColor = vec4(velocity * (1.0 - 0.1 * u_dt) + u_dt * totalForce, 1.0);
    } else {
        // Return the original particle velocity
        gl_FragColor = vec4(velocity, 1.0);
    }
}
