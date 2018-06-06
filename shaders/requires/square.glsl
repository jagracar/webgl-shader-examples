/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the square
 */
float square(vec2 pixel, vec2 bottom_left, float side) {
    vec2 top_right = bottom_left + side;

    return step(bottom_left.x, pixel.x) * step(bottom_left.y, pixel.y) * step(pixel.x, top_right.x)
            * step(pixel.y, top_right.y);
}

#pragma glslify: export(square)
