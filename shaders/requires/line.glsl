/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the line
 */
float line(vec2 pixel, vec2 start, vec2 end, float width) {
    vec2 pixel_dir = pixel - start;
    vec2 line_dir = end - start;
    float line_length = length(line_dir);
    float projected_dist = dot(pixel_dir, line_dir) / line_length;
    float tanjential_dist_sq = dot(pixel_dir, pixel_dir) - pow(projected_dist, 2.0);
    float width_sq = pow(width, 2.0);
    float delta = min(3.0 / width, 0.7);

    return step(0.0, projected_dist) * step(0.0, line_length - projected_dist)
            * (1.0 - smoothstep(1.0 - delta, 1.0 + delta, tanjential_dist_sq / width_sq));
}

#pragma glslify: export(line)
