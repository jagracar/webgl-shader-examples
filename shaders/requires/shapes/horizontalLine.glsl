/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the horizontal line
 */
float horizontalLine(vec2 pixel, float y_pos, float width) {
    return 1.0 - smoothstep(-1.0, 1.0, abs(pixel.y - y_pos) - 0.5 * width);
}

#pragma glslify: export(horizontalLine)
