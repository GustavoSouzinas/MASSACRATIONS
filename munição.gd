extends Label

@onready var player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if player:
		var arma = player.aparato_atual
		var atual = player.ammo[arma]
		var maximo = player.ammo_max[arma]
		
		text = "%d / %d" % [atual, maximo]
		
		if atual <= 0:
			text = "CABOU"
			modulate = Color(1,0,0)
		else: 
			modulate = Color(1,1,1)
