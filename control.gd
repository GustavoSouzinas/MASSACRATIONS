extends Control

@onready var player = get_tree().get_first_node_in_group("player")

@onready var icon = $TextureRect
@onready var text = $Label

func _process(delta):
	if not player:
		return

	var cheio = player.bateria >= player.bateria_max

	icon.visible = cheio
	text.visible = cheio
