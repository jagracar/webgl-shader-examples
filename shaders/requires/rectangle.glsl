/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the rectangle
 */
float rectangle(vec2 pixel, vec2 bottom_left, vec2 sides) {
    vec2 top_right = bottom_left + sides;

    return step(bottom_left.x, pixel.x) * step(bottom_left.y, pixel.y) * step(pixel.x, top_right.x)
            * step(pixel.y, top_right.y);
}

#pragma glslify: export(rectangle)
