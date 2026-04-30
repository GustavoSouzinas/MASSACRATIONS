extends AudioStreamPlayer

var player = null

var min_db = -20.0
var max_db = -1.0

func _process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	var t = player.get_cortisol_normalizado()
	var target_db = lerp(min_db, max_db, t)
	
	volume_db = lerp(volume_db, target_db, delta * 3.0)
