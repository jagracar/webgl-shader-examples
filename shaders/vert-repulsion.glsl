// Particle index attribute
attribute float a_index;

// Simulation uniforms
uniform float u_width;
uniform float u_height;
uniform float u_particleSize;
uniform float u_nActiveParticles;
uniform sampler2D u_positionTexture;
uniform sampler2D u_velocityTexture;

// Particle color varying
varying vec3 v_color;

/*
 * The main program
 */
void main() {
    // Check if the particle is one of the active particles
    if (a_index < u_nActiveParticles) {
        // Get the particle position and velocity
        vec2 uv = vec2((mod(a_index, u_width) + 0.5) / u_width, (floor(a_index / u_width) + 0.5) / u_height);
        vec3 position = texture2D(u_positionTexture, uv).xyz;
        vec3 velocity = texture2D(u_velocityTexture, uv).xyz;

        // Calculate the model view position
        vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);

        // Calculate the particle color based on its velocity
        v_color = mix(vec3(1.0, 0.0, 0.0), vec3(1.0, 1.0, 0.0), 20.0 * length(velocity));

        // Vertex shader output
        gl_PointSize = -u_particleSize / mvPosition.z;
        gl_Position = projectionMatrix * mvPosition;
    } else {
        // Vertex shader output
        gl_PointSize = 0.0;
        gl_Position = vec4(-1000000.0);
    }
}
