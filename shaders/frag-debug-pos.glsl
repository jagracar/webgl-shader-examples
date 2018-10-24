void main() {
    vec2 uv = gl_FragCoord.xy / resolution;
    vec3 position = texture2D(u_positionTexture, uv).xyz;
    vec3 velocity = texture2D(u_velocityTexture, uv).xyz;

    gl_FragColor = vec4(position + velocity, 1.0);
}
