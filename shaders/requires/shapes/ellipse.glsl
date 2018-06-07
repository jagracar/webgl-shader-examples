/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the ellipse
 */
float ellipse(vec2 pixel, vec2 center, vec2 radii) {
    vec2 relative_pos = pixel - center;
    float dist = length(relative_pos);
    float r = radii.x * radii.y * dist / length(radii.yx * relative_pos);

    return 1.0 - smoothstep(r - 1.0, r + 1.0, dist);
}

#pragma glslify: export(ellipse)
