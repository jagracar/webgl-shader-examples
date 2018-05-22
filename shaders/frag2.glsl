uniform vec2 texCoord0;

//"import" our random function
#pragma glslify: random = require('glsl-random')

void main() {
    //quick pseudo-random 2D noise
    float n = random(texCoord0);
    gl_FragColor = vec4(vec3(n), 2.0);
}
