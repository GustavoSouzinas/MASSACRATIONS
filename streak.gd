extends Control

@export var reset_time := 2.0

@onready var streak: Label = $streak
@onready var streak2: Label = $streak2

var combo := 0
var timer := 0.0

var base_scale := Vector2.ONE
var base_rotation := 0.0
var hue_timer := 0.0

func _ready():
	visible = false
	base_scale = scale
	base_rotation = rotation
	pivot_offset = size / 2

func _process(delta):
	if combo <= 0:
		return

	timer += delta
	hue_timer += delta * 2.0

	if timer >= reset_time:
		reset_combo()
		return

	var t: float = clamp(combo / 20.0, 0.0, 1.0)

	# shake geral
	position += Vector2(
		randf_range(-2, 2) * t,
		randf_range(-2, 2) * t
	)

	# scale geral
	#scale = base_scale * (1.0 + t * 0.35)

	# sway geral
	var sway_speed := 3.0 + t * 10.0
	var sway_amount := 2.0 + t * 12.0
	rotation = base_rotation + sin(hue_timer * sway_speed) * deg_to_rad(sway_amount)

	# cor só no número
	var intensity: float = t
	var base_hue := intensity * 0.33
	var dynamic := fmod(hue_timer * (1.0 + intensity * 6.0), 1.0)
	var hue := base_hue + dynamic * intensity

	streak.modulate = Color.from_hsv(fmod(hue, 1.0), 0.9, 1.0)

func registrar_kill():
	combo += 1
	timer = 0.0

	if not visible:
		visible = true
		pop_in()

	streak.text = str(combo)
	streak2.text = "X"

func reset_combo():
	combo = 0
	timer = 0.0
	visible = false

	scale = base_scale
	rotation = base_rotation

	streak.modulate = Color.WHITE

func pop_in():
	scale = base_scale * 0.5

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", base_scale * 1.2, 0.15)\
		.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)
# DEBUG	
#func _input(event):
#	if event is InputEventKey:
#		if event.keycode == KEY_K and event.pressed:
#			registrar_kill()
