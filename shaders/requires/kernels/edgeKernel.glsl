// Edge detection kernel
const mat3 kernel = mat3(-1.0, -1.0, -1.0,
                         -1.0, +8.0, -1.0,
                         -1.0, -1.0, -1.0);

#pragma glslify: export(kernel)
