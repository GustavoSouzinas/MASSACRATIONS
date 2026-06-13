extends TextureRect

@onready var player = get_tree().get_first_node_in_group("player")

var shake_intensity := 0.0
var original_position := Vector2.ZERO

func _ready():
	original_position = position

func _process(_delta):
	if not player:
		return

	var percent = player.bateria / player.bateria_max

	if percent >= 1.0:
		shake_intensity = 3.0
	else:
		shake_intensity = 0.0
		position = original_position
		return

	var offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)

	position = original_position + offset
