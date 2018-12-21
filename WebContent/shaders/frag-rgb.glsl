#define GLSLIFY 1
// Common uniforms
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_frame;

// Texture uniforms
uniform sampler2D u_texture;

// Texture varyings
varying vec2 v_uv;

/*
 * The main program
 */
void main() {
    // Calculate the color offset directions
    float angle = u_time;
    vec2 red_offset = vec2(cos(angle), sin(angle));
    angle += radians(120.0);
    vec2 green_offset = vec2(cos(angle), sin(angle));
    angle += radians(120.0);
    vec2 blue_offset = vec2(cos(angle), sin(angle));

    // Calculate the offset size as a function of the pixel distance to the center
    float offset_size = 0.1 * length(gl_FragCoord.xy - 0.5 * u_resolution);

    // Scale the offset size by the relative mouse position
    offset_size *= u_mouse.x / u_resolution.x;

    // Extract the pixel color values from the input texture
    float red = texture2D(u_texture, v_uv - offset_size * red_offset / u_resolution).r;
    float green = texture2D(u_texture, v_uv - offset_size * green_offset / u_resolution).g;
    float blue = texture2D(u_texture, v_uv - offset_size * blue_offset / u_resolution).b;

    // Fragment shader output
    gl_FragColor = vec4(red, green, blue, 1.0);
}
