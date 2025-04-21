shader_type canvas_item;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

 vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
 uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
 void fragment()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = UV;

    // Time varying pixel color
    vec3 source = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

    vec3 hsv = rgb2hsv(source);
    hsv.x = (0.61 * 360.0) / 60.0;

    vec3 dst = hsv2rgb(hsv);
    // Output to screen
    COLOR = vec4(dst,1.0);
}