/*
 * Returns a value between 1 and 0 that indicates if the pixel is inside the line
 */
float line(vec2 pixel, vec2 point, vec2 line_dir, float width) {
    vec2 pixel_dir = pixel - point;
    float projected_dist = dot(pixel_dir, normalize(line_dir));
    float tanjential_dist = sqrt(dot(pixel_dir, pixel_dir) - projected_dist * projected_dist);

    return 1.0 - smoothstep(-1.0, 1.0, tanjential_dist - 0.5 * width);
}

#pragma glslify: export(line)
