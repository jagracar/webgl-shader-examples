#define GLSLIFY 1
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

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
	float max_dim = max(u_resolution.x, u_resolution.y);
	vec2 rel_pixel_pos = gl_FragCoord.xy / max_dim;
	vec2 p = floor(20.0 * rel_pixel_pos);

	gl_FragColor = vec4(vec3(random(p), random(20.0 * p), 1.0), 1.0);
}
