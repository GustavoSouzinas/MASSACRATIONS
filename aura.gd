extends TextureRect

@onready var gain = $"../aura/aura_gain"

var combo = 0
var max_combo = 100
var original_position

func _ready():
	original_position = position
	pivot_offset = size / 2

# tempo sem ganhar combo
var decay_timer = 0.0

# de quantos em quantos segundos perde aura
var decay_delay = 1.0

# quanto perde por tick
var decay_amount = 5

var aura_levels = [
	preload("res://assets/scenes/player/gui/Aura1.png"),
	preload("res://assets/scenes/player/gui/Aura2.png"),
	preload("res://assets/scenes/player/gui/Aura3.png"),
	preload("res://assets/scenes/player/gui/Aura4.png"),
	preload("res://assets/scenes/player/gui/Aura5.png"),
	preload("res://assets/scenes/player/gui/Aura6.png"),
]

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_F and event.pressed:
			adicionar_combo(20)

func _process(delta):

	if combo > 60:
		position = original_position + Vector2(
			randf_range(-2, 2),
			randf_range(-2, 2)
		)
	else:
		position = original_position

	decay_timer += delta

	if decay_timer >= decay_delay:
		perder_combo(decay_amount)
		decay_timer = 0.0

func adicionar_combo(valor):

	# reseta o timer quando ganha combo
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
