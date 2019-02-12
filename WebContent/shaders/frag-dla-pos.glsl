#define GLSLIFY 1
/*
 * Random number generator with a vec2 seed
 *
 * Credits:
 * http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0
 * https://github.com/mattdesl/glsl-random
 */
highp float random2d(vec2 co) {
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt = dot(co.xy, vec2(a, b));
    highp float sn = mod(dt, 3.14);
    return fract(sin(sn) * c);
}

// Simulation uniforms
uniform float u_minDistance;
uniform float u_maxDistance;
uniform float u_time;

// Simulation constants
const float width = resolution.x;
const float height = resolution.y;
const float nParticles = width * height;

/*
 * The main program
 */
void main() {
    // Get the particle texture position
    vec2 uv = gl_FragCoord.xy / resolution;

    // Get the particle current position
    vec4 position = texture2D(u_positionTexture, uv);

    // Update the particle position if it has not been aggregated
    if (position.w > 0.0) {
        // Move the particle to a new random position
        float ang = 2.0 * 3.141593 * random2d(123.456 * position.xy + u_time);
        position.xy += 0.9 * u_minDistance * vec2(cos(ang), sin(ang));

        // Loop over all the particles in the simulation
        for (float i = 0.0; i < nParticles; i++) {
            // Get the particle position and velocity
            vec2 particleUv = vec2(mod(i, width) + 0.5, floor(i / width) + 0.5) / resolution;
            vec4 particlePosition = texture2D(u_positionTexture, particleUv);

            // Check if it's an aggregated particle
            if (position.w > 0.0 && particlePosition.w < 0.0) {
                // Calculate the distance between the two particles
                float distance = length(particlePosition.xy - position.xy);

                // Set the particle as aggregated if the distance is small
                // enough and we are not comparing the particle with itself
                if (distance != 0.0 && distance < u_minDistance) {
                    position.w = -1.0;
                    position.xy = particlePosition.xy + u_minDistance * (position.xy - particlePosition.xy) / distance;
                    break;
                }
            }
        }

        // Make sure that the particle distance to the center is smaller than
        // the maximum allowed distance
        float distanceToCenter = length(position.xy);

        if (distanceToCenter > u_maxDistance) {
            position.xy -= 2.0 * u_maxDistance * position.xy / distanceToCenter;
        }
    }

    // Return the updated particle position
    gl_FragColor = position;
}
