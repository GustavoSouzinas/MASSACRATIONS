extends Sprite2D

@onready var player = get_tree().get_first_node_in_group("player")

var min_angle = deg_to_rad(-90)
var max_angle = deg_to_rad(90)

func _process(delta):
	if player:
		var t = player.get_cortisol_normalizado()
		var target_angle = lerp(min_angle, max_angle, t)
		
		# interpolação suave
		rotation = lerp(rotation, target_angle, delta * 5.0)
