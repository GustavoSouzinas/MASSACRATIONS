shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// controla “resolução fake” (quanto maior, mais pixelado)
uniform float pixel_size = 2.0;

// quantização de cores (PS1 tinha poucas cores efetivas)
uniform float color_levels = 32.0;

// matriz de dithering 4x4 (estilo PS1 clássico)
float dither4x4(vec2 pos) {
    int x = int(mod(pos.x, 4.0));
    int y = int(mod(pos.y, 4.0));

    int index = x + y * 4;

    float matrix[16] = float[](
        0.0,  8.0,  2.0, 10.0,
        12.0, 4.0, 14.0, 6.0,
        3.0, 11.0, 1.0, 9.0,
        15.0, 7.0, 13.0, 5.0
    );

    return matrix[index] / 16.0;
}

void fragment() {
    // 1. “pixelização”
    vec2 uv = SCREEN_UV;
	vec2 pixel_uv = floor(uv * (1.0 / SCREEN_PIXEL_SIZE) / pixel_size) * pixel_size * SCREEN_PIXEL_SIZE;
    vec4 color = texture(SCREEN_TEXTURE, pixel_uv);

    // 2. dithering (ruído de quantização)
    float dither = dither4x4(FRAGCOORD.xy);
    color.rgb += (dither - 0.5) / color_levels;

    // 3. redução de cores (PS1 look real)
    color.rgb = floor(color.rgb * color_levels) / color_levels;

    COLOR = color;
}