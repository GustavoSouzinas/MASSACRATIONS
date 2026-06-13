extends TextureRect

@export var music_bus := "Music"

@export_group("Pulse")
@export var pulse_strength := 0.1
@export var pulse_speed := 0.15
@export var multiplier := 50.0
@export var base_scale := 0.8

var pos_hidden: Vector2
var base_position: Vector2

var tween: Tween
var spectrum

var target_scale := 1.0
var current_scale := 1.0

func _ready():
	base_position = position
	pos_hidden = base_position - Vector2(0, 80)

	position = pos_hidden
	modulate.a = 0.0

	spectrum = AudioServer.get_bus_effect_instance(
		AudioServer.get_bus_index(music_bus),
		0
	)

func _process(_delta):
	if spectrum == null:
		return

	var magnitude = spectrum.get_magnitude_for_frequency_range(20, 120)
	var energy = magnitude.length()

	var raw = energy * multiplier
	raw = log(1.0 + raw)
	raw = clamp(raw, 0.0, 1.0)

	if raw > target_scale:
		raw = lerp(target_scale, raw, 0.35)

	target_scale = 1.0 + raw * pulse_strength

	current_scale = lerp(
		current_scale,
		target_scale,
		pulse_speed
	)

	scale = Vector2.ONE * (base_scale * current_scale)

func show_mp3():
	if tween:
		tween.kill()

	var target_pos = position + Vector2(0, 0)

	tween = create_tween()
	tween.set_parallel()

	tween.tween_property(self, "position", target_pos, 0.5)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func hide_mp3():
	if tween:
		tween.kill()

	var target_pos = position - Vector2(0, 80)

	tween = create_tween()
	tween.set_parallel()

	tween.tween_property(self, "position", target_pos, 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
