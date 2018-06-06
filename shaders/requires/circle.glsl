/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the circle
 */
float circle(vec2 pixel, vec2 center, float radius) {
    vec2 relative_pos = (pixel - center) / radius;
    float delta = min(2.5 / radius, 0.1);

    return 1.0 - smoothstep(1.0 - delta, 1.0 + delta, dot(relative_pos, relative_pos));
}

#pragma glslify: export(circle)
