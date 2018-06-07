/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the square
 */
float square(vec2 pixel, vec2 bottom_left, float side) {
    vec2 top_right = bottom_left + side;

    return smoothstep(-1.0, 1.0, pixel.x - bottom_left.x) * smoothstep(-1.0, 1.0, pixel.y - bottom_left.y)
            * smoothstep(-1.0, 1.0, top_right.x - pixel.x) * smoothstep(-1.0, 1.0, top_right.y - pixel.y);
}

#pragma glslify: export(square)
