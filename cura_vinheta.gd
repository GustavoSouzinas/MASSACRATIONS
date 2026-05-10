extends TextureRect

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	modulate.a = 0.0

func tocar():

	scale = Vector2(1.0, 1.0)
	modulate.a = 1.0

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		self,
		"scale",
		Vector2(1.3, 1.3),
		0.25
	)

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		0.35
	)
