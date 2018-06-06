/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the ellipse
 */
float ellipse(vec2 pixel, vec2 center, vec2 radii) {
    vec2 relative_pos = (pixel - center) / radii;
    float delta = min(2.5 / min(radii.x, radii.y), 0.1);

    return 1.0 - smoothstep(1.0 - delta, 1.0 + delta, dot(relative_pos, relative_pos));
}

#pragma glslify: export(ellipse)
