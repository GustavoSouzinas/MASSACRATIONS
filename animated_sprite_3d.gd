extends AnimatedSprite3D

var anim_map = {
	0: "default",
	1: "cumbuca",
	2: "badogue"
}

var travado = false

func tocar_animacao_unica(nome):
	travado = true
	play(nome)

	await animation_finished

	travado = false

func _process(_delta):

	if travado:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var arma = player.aparato_atual
	var aparato_nome = anim_map.get(arma)

	if aparato_nome == null:
		return

	# BADOGUE SHOOT
	if arma == 2 and player.badogue_shooting:
		aparato_nome = "badogue shoot"

	# escala
	match aparato_nome:
		"badogue shoot":
			scale = Vector3(0.09, 0.09, 0.09)

		"badogue":
			scale = Vector3(0.09, 0.09, 0.09)

		"default":
			scale = Vector3(0.1, 0.1, 0.1)

		"cumbuca":
			scale = Vector3(0.1, 0.1, 0.1)

		_:
			scale = Vector3.ONE

	if animation != aparato_nome:
		play(aparato_nome)


func _on_animation_finished():

	var player = get_tree().get_first_node_in_group("player")

	if player and animation == "badogue shoot":
		player.badogue_shooting = false
		play("badogue")
