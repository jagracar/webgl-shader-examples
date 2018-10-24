#define GLSLIFY 1
void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec3 velocity = texture2D(u_velocityTexture, uv).xyz;

    gl_FragColor = vec4(velocity, 1.0);
}
