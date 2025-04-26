shader_type canvas_item;
#define TILE_SIZE 8.0
varying float wow;
uniform float Amount = 1.0;
varying vec2 size;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture,filter_linear_mipmap;

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

vec3 posterize(vec3 color, float steps)
{
    return floor(color * steps) / steps;
}

float quantize(float n, float steps)
{
    return floor(n * steps) / steps;
}

vec4 downsample(sampler2D sampler, vec2 uv, float pixelSize)
{
    return texture(sampler, uv - mod(uv, vec2(pixelSize) / size));
}

float rand(float n)
{
    return fract(sin(n) * 43758.5453123);
}

float noise(float p)
{
    float fl = floor(p);
  	float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

float rand2(vec2 n)
{
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise2(vec2 p)
{
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);

    float res = mix(
        mix(rand2(ip), rand2(ip + vec2(1.0, 0.0)), u.x),
        mix(rand2(ip + vec2(0.0,1.0)), rand2(ip + vec2(1.0,1.0)), u.x), u.y);
    return res * res;
}

vec3 edge(sampler2D sampler, vec2 uv, float sampleSize)
{
    float dx = sampleSize / size.x;
    float dy = sampleSize / size.y;
    return (
    mix(downsample(sampler, uv - vec2(dx, 0.0), sampleSize), downsample(sampler, uv + vec2(dx, 0.0), sampleSize), mod(uv.x, dx) / dx) +
    mix(downsample(sampler, uv - vec2(0.0, dy), sampleSize), downsample(sampler, uv + vec2(0.0, dy), sampleSize), mod(uv.y, dy) / dy)
    ).rgb / 2.0 - texture(sampler, uv).rgb;
}

vec3 distort(sampler2D sampler, vec2 uv, float edgeSize)
{
    vec2 pixel = vec2(1.0) / size.y;
    vec3 field = rgb2hsv(edge(sampler, uv, edgeSize));
    vec2 distort = pixel * sin((field.rb) * PI * 2.0);
    float shiftx = noise2(vec2(quantize(uv.y + 31.5, size.y / TILE_SIZE) * TIME, fract(TIME) * 300.0));
    float shifty = noise2(vec2(quantize(uv.x + 11.5, size.x / TILE_SIZE) * TIME, fract(TIME) * 100.0));
    vec3 rgb = texture(sampler, uv + (distort + (pixel - pixel / 2.0) * vec2(shiftx, shifty) * (50.0 + 100.0 * Amount)) * Amount).rgb;
    vec3 hsv = rgb2hsv(rgb);
    return posterize(hsv2rgb(hsv), floor(mix(256.0, pow(1.0 - hsv.z - 0.5, 2.0) * 64.0 * shiftx + 4.0, 1.0 - pow(1.0 - Amount, 5.0))));
}

void fragment()
{
	size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = SCREEN_UV;
    wow = clamp(mod(noise(TIME + uv.y), 1.0), 0.0, 1.0) * 2.0 - 1.0;
    vec3 finalColor;
    finalColor = distort(SCREEN_TEXTURE, uv, 8.0);
    COLOR = vec4(finalColor, 1.0);
}