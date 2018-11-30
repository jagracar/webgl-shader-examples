// Particle index attribute
attribute float a_index;

// Simulation uniforms
uniform float u_width;
uniform float u_height;
uniform float u_particleSize;
uniform float u_nActiveParticles;
uniform sampler2D u_positionTexture;
uniform sampler2D u_bgTexture;
uniform vec2 u_textureOffset;

/*
 * Returns the texture background color at the given position
 */
vec3 get_background_color(vec3 position) {
    return texture2D(u_bgTexture, (position.xy + u_textureOffset) / (2.0 * u_textureOffset)).rgb;
}

/*
 * The main program
 */
void main() {
    // Check if the particle is one of the active particles
    if (a_index < u_nActiveParticles) {
        // Get the particle position
        vec2 uv = vec2((mod(a_index, u_width) + 0.5) / u_width, (floor(a_index / u_width) + 0.5) / u_height);
        vec3 position = texture2D(u_positionTexture, uv).xyz;

        // Calculate the model view position
        vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);

        // Calculate the particle relative size based on the background texture color
        vec3 bgColor = get_background_color(position);
        float relativeSize = 1.0 - 0.3 * dot(bgColor, vec3(1.0));

        // Vertex shader output
        gl_PointSize = -u_particleSize * relativeSize / mvPosition.z;
        gl_Position = projectionMatrix * mvPosition;
    } else {
        // Vertex shader output
        gl_PointSize = 0.0;
        gl_Position = vec4(-1000000.0);
    }
}
