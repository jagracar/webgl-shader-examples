attribute vec2 reference;
uniform sampler2D u_positionTexture;

void main() {
    gl_PointSize = 2.0;
    gl_Position = projectionMatrix * modelViewMatrix * texture2D(u_positionTexture, reference);
}
