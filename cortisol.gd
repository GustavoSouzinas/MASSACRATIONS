extends TextureRect

var intensidade_max = 10.0
var velocidade = 30.0

var player = null
var pos_base = Vector2.ZERO

func _ready():
	pos_base = position

func _process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	var t = player.get_cortisol_normalizado() # 0 → 1
	
	# intensidade cresce com pressão
	var intensidade = t * intensidade_max
	
	# tremor aleatório
	var offset = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	) * intensidade
	
	position = pos_base + offset
