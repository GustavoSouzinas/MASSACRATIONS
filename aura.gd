extends TextureRect

signal insanity_frame_changed(frame: bool)
signal insanity_ended

@onready var gain = $"../aura/aura_gain"
var combo = 0
var max_combo = 100
var original_position

func _ready():
	original_position = position
	pivot_offset = size / 2

var decay_timer = 0.0
var decay_delay = 1.0
var decay_amount = 5
var max_aura_timer = 0.0
var insanity_timer = 0.0
var insanity_frame = false
var aura_levels = [
	preload("res://assets/scenes/player/gui/Aura1.png"),
	preload("res://assets/scenes/player/gui/Aura2.png"),
	preload("res://assets/scenes/player/gui/Aura3.png"),
	preload("res://assets/scenes/player/gui/Aura4.png"),
	preload("res://assets/scenes/player/gui/Aura5.png"),
	preload("res://assets/scenes/player/gui/Aura6.png"),
	preload("res://assets/scenes/player/gui/Aura67-1.png"),
	preload("res://assets/scenes/player/gui/Aura67-2.png"),
]

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_F and event.pressed:
			adicionar_combo(20)

func _process(delta):
	if combo > 60:
		position = original_position + Vector2(randf_range(-2, 2), randf_range(-2, 2))
	else:
		position = original_position

	decay_timer += delta
	if decay_timer >= decay_delay:
		perder_combo(decay_amount)
		decay_timer = 0.0

	if combo >= max_combo:
		max_aura_timer += delta
		if max_aura_timer >= 2.0:
			insanity_timer += delta
			if insanity_timer >= 0.08:
				insanity_timer = 0.0
				insanity_frame = !insanity_frame
				if insanity_frame:
					texture = aura_levels[6]
				else:
					texture = aura_levels[7]
				emit_signal("insanity_frame_changed", insanity_frame)
	else:
		if max_aura_timer > 0.0:
			emit_signal("insanity_ended")
		max_aura_timer = 0.0

func adicionar_combo(valor):
	decay_timer = 0.0
	combo += valor
	combo = clamp(combo, 0, max_combo)
	gain.criar_popup("+ AURA", Color.GREEN)
	atualizar_aura()

func perder_combo(valor):
	combo -= valor
	combo = clamp(combo, 0, max_combo)
	gain.criar_popup("- AURA", Color.RED)
	atualizar_aura()

func atualizar_aura():
	if max_aura_timer >= 5.0 and combo >= max_combo:
		return
	if combo < 20:
		texture = aura_levels[0]
	elif combo < 40:
		texture = aura_levels[1]
	elif combo < 60:
		texture = aura_levels[2]
	elif combo < 80:
		texture = aura_levels[3]
	elif combo < 100:
		texture = aura_levels[4]
	else:
		texture = aura_levels[5]
