// Approximate gaussian kernel
const mat3 kernel = mat3(1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0,
                         2.0 / 16.0, 4.0 / 16.0, 2.0 / 16.0,
                         1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0);

#pragma glslify: export(kernel)
