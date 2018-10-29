#define GLSLIFY 1
attribute float a_index;

uniform float u_width;
uniform float u_height;
uniform sampler2D u_positionTexture;

void main() {
    vec2 uv = vec2((mod(a_index, u_width) + 0.5) / u_width, (floor(a_index / u_width) + 0.5) / u_height);
    gl_PointSize = 2.0;
    gl_Position = projectionMatrix * modelViewMatrix * texture2D(u_positionTexture, uv);
}
