/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the line segment
 */
float lineSegment(vec2 pixel, vec2 start, vec2 end, float width) {
    vec2 pixel_dir = pixel - start;
    vec2 line_dir = end - start;
    float line_length = length(line_dir);
    float projected_dist = dot(pixel_dir, line_dir) / line_length;
    float tanjential_dist = sqrt(dot(pixel_dir, pixel_dir) - projected_dist * projected_dist);

    return smoothstep(-1.0, 1.0, projected_dist) * smoothstep(-1.0, 1.0, line_length - projected_dist)
            * (1.0 - smoothstep(-1.0, 1.0, tanjential_dist - 0.5 * width));
}

#pragma glslify: export(lineSegment)
