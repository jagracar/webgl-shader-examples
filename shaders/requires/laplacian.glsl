/*
 *  Calculates the Laplacian at a given texture position
 */
vec4 laplacian(vec2 uv, sampler2D texture, vec2 texture_size) {
    // Calculate the texture steps
    float du = 1.0 / texture_size.x;
    float dv = 1.0 / texture_size.y;

    // Calculate the laplacian
    vec4 lap = -texture2D(texture, uv);
    lap += 0.2 * texture2D(texture, uv + vec2(-du, 0.0));
    lap += 0.2 * texture2D(texture, uv + vec2(du, 0.0));
    lap += 0.2 * texture2D(texture, uv + vec2(0.0, -dv));
    lap += 0.2 * texture2D(texture, uv + vec2(0.0, dv));
    lap += 0.05 * texture2D(texture, uv + vec2(-du, -dv));
    lap += 0.05 * texture2D(texture, uv + vec2(du, -dv));
    lap += 0.05 * texture2D(texture, uv + vec2(du, dv));
    lap += 0.05 * texture2D(texture, uv + vec2(-du, dv));

    return lap;
}

#pragma glslify: export(laplacian)
