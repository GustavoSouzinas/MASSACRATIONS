extends TextureProgressBar

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player:
		max_value = player.bateria_max

func _process(delta):
	if not player:
		return
	max_value = player.bateria_max
	value = player.bateria
	atualizar_cor()

func atualizar_cor():
	if max_value == 0:
		return
	var percent = value / max_value
	if percent <= 0.5:
		modulate = Color(1, percent * 2, 0)
	else:
		modulate = Color(1 - (percent - 0.5) * 2, 1, 0)
