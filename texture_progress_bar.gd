extends TextureProgressBar

@onready var aura = get_parent()

var aura_levels = [
	preload("res://assets/scenes/player/gui/Aura67-1_overlap.png"),
	preload("res://assets/scenes/player/gui/Aura67-2_overlap.png"),
]

var vida_atual : float = 100
var vida_maxima : float = 100
var texture_default: Texture2D

func _ready() -> void:
	texture_default = texture_progress
	aura.insanity_frame_changed.connect(_on_insanity_frame_changed)
	aura.insanity_ended.connect(_on_insanity_ended)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vida_alterada.connect(_ao_mudar_vida)
		vida_atual = player.vida
		vida_maxima = player.vida_maxima
		max_value = vida_maxima
		value = vida_atual

func _on_insanity_frame_changed(frame: bool) -> void:
	if frame:
		texture_progress = aura_levels[0]
	else:
		texture_progress = aura_levels[1]

func _on_insanity_ended() -> void:
	texture_progress = texture_default

func _ao_mudar_vida(nova_vida: int):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "value", float(nova_vida), 0.25)
	vida_atual = nova_vida
	modulate = Color(1, 0.3, 0.3)
	var flash = create_tween()
	flash.tween_property(self, "modulate", Color.WHITE, 0.3)
