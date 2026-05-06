extends CanvasLayer

@onready var label_morte = $morte

var player = null
var morte_visivel = false

func _ready():
	label_morte.visible = false
	label_morte.modulate.a = 0.0
	_conectar_player()

func _conectar_player():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if player.has_signal("vida_alterada"):
		if not player.vida_alterada.is_connected(_on_vida_alterada):
			player.vida_alterada.connect(_on_vida_alterada)

func _on_vida_alterada(valor):
	if valor <= 0:
		mostrar_morte()
	else:
		esconder_morte()

func mostrar_morte():
	if morte_visivel:
		return

	morte_visivel = true
	label_morte.visible = true
	label_morte.modulate.a = 1.0
	label_morte.scale = Vector2.ONE

func esconder_morte():
	if not morte_visivel:
		return

	morte_visivel = false
	label_morte.visible = false
	label_morte.modulate.a = 0.0
	label_morte.scale = Vector2.ONE
