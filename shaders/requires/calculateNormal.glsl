/*
 *  Calculates the normal vector at the given position
 */
vec3 calculateNormal(vec3 position) {
    return cross(dFdx(position), dFdy(position));
}

#pragma glslify: export(calculateNormal)
