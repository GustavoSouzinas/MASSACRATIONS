shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float pixel_size = 2.0;
uniform float color_steps = 32.0;
uniform float chroma = 1.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	vec2 size = vec2(1.0) / SCREEN_PIXEL_SIZE;
	vec2 grid = floor((uv * size) / pixel_size) * pixel_size;
	vec2 snapped_uv = grid / size;

	vec2 px = SCREEN_PIXEL_SIZE * chroma;

	float r = texture(screen_texture, snapped_uv + vec2(px.x, 0.0)).r;
	float g = texture(screen_texture, snapped_uv).g;
	float b = texture(screen_texture, snapped_uv - vec2(px.x, 0.0)).b;

	vec3 col = vec3(r, g, b);

	col = floor(col * color_steps) / color_steps;

	float dither = fract(sin(dot(floor(uv * size), vec2(12.9898, 78.233))) * 43758.5453);
	col += (dither - 0.5) / color_steps;

	COLOR = vec4(col, 1.0);
}