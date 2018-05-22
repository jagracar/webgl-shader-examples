#define GLSLIFY 1
uniform vec2 texCoord0;

//"import" our random function
highp float random(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

void main() {
    //quick pseudo-random 2D noise
    float n = random(texCoord0);
    gl_FragColor = vec4(vec3(n), 2.0);
}
