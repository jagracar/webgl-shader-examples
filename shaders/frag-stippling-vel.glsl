// Simulation uniforms
uniform float u_dt;
uniform float u_nActiveParticles;
uniform sampler2D u_bgTexture;
uniform vec2 u_textureOffset;

// Simulation constants
const float width = resolution.x;
const float height = resolution.y;
const float nParticles = width * height;

// Softening factor. This is required to avoid high acceleration values when
// two particles get too close
const float softening = 0.03;

/*
 * Returns the texture background color at the given position
 */
vec3 get_background_color(vec3 position) {
    return texture2D(u_bgTexture, (position.xy + u_textureOffset) / (2.0 * u_textureOffset)).rgb;
}

/*
 * Calculates the charge size for the given background color
 */
float calculate_charge_size(vec3 bgColor) {
    return 0.045 + 0.03 * pow(dot(bgColor, vec3(1.0)), 2.0);
}

/*
 * The main program
 */
void main() {
    // Get the particle texture position
    vec2 uv = gl_FragCoord.xy / resolution;

    // Check if the particle is one of the active particles
    if ((gl_FragCoord.x - 0.5) + (gl_FragCoord.y - 0.5) * width < u_nActiveParticles) {
        // Get the particle current position
        vec3 position = texture2D(u_positionTexture, uv).xyz;

        // Get the particle charge size based on the background color
        vec3 bgColor = get_background_color(position);
        float chargeSize = calculate_charge_size(bgColor);

        // Calculate the maximum distance at which the particle could be
        // affected by other particles
        float maxDistance = chargeSize + calculate_charge_size(vec3(1.0));

        // Loop over all the particles and calculate the total repulsion force
        vec3 totalForce = vec3(0.0);

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
            // indicates that we are comparing the particle with itself, or the
            // distance is larger than the maximum influence distance
            if (distance == 0.0 || distance > maxDistance) {
                continue;
            }

            // Get the repulsing particle charge size based on the background color
            vec3 particleBgColor = get_background_color(particlePosition);
            float particleChargeSize = calculate_charge_size(particleBgColor);

            // Calculate the total charge range
            float totalChargeSize = chargeSize + particleChargeSize;

            // Check that the distance is smaller than the total charge size
            if (distance < totalChargeSize) {
                // Add the particle repulsion force
                totalForce += 0.03 * pow(totalChargeSize / (distance + softening), 2.0) * (forceDirection / distance);
            }
        }

        // Return the new particle velocity
        gl_FragColor = vec4(u_dt * totalForce, 1.0);
    } else {
        // Return the original particle velocity
        gl_FragColor = texture2D(u_velocityTexture, uv);
    }
}
