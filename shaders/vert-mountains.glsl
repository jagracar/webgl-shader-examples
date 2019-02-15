#pragma glslify: import("./imports/commonUniforms.glsl")
#pragma glslify: import("./imports/commonVaryings3d.glsl")
#pragma glslify: noise = require("./requires/classicNoise2d")

// The plane tile size, the flying speed and the maximum mountain height
uniform float u_tileSize;
uniform float u_speed;
uniform float u_maxHeight;

varying float v_height;

vec3 getCurrentPosition(vec3 initialPosition) {
    float horizontalShift = mod(u_speed * u_time, u_tileSize);
    float verticalShift = u_maxHeight
            * noise(0.03 * (initialPosition.xz - vec2(0.0, u_tileSize * floor(u_speed * u_time / u_tileSize))));
    verticalShift = max(-0.6 * u_maxHeight, verticalShift);

    return initialPosition + vec3(0.0, verticalShift, horizontalShift);
}

/*
 * The main program
 */
void main() {
    // Calculate the new vertex position
    vec3 newPosition = getCurrentPosition(position);

    // Calculate the modelview position
    vec4 mv_position = modelViewMatrix * vec4(newPosition, 1.0);

    // Save the varyings
    v_position = mv_position.xyz;
    v_height = newPosition.y;

    // Vertex shader output
    gl_Position = projectionMatrix * mv_position;
}
