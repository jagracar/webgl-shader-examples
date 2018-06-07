/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the circle
 */
float circle(vec2 pixel, vec2 center, float radius) {
    return 1.0 - smoothstep(radius - 1.0, radius + 1.0, length(pixel - center));
}

#pragma glslify: export(circle)
