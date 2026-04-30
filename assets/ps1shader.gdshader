shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment() {
    // Esse código pega o que a câmera está vendo e desenha no ColorRect
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    COLOR = color;
}