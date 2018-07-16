/*
 *  Calculates the diffuse factor produced by the light illumination
 */
float diffuseFactor(vec3 normal, vec3 light_direction) {
    return -dot(normalize(normal), normalize(light_direction));
}

#pragma glslify: export(diffuseFactor)
