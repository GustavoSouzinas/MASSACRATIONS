extends AnimatedSprite3D

var anim_map = {
	0: "default",
	1: "cumbuca"
}

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var arma = player.aparato_atual
	var aparato_nome = anim_map.get(arma)

	if aparato_nome == null:
		return

	if animation != aparato_nome:
		play(aparato_nome)
