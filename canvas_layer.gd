<<<<<<< HEAD
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
=======
extends Label

var efeito_ativo = false
var hue_timer = 0.0
#DEBUG
#func _input(event):
#	if event is InputEventKey:
#		if event.keycode == KEY_F and event.pressed:
#			var frases = ["VC É CHAD", "BETINHA?", "SKILL ISSUE", "QUE AUDÁCIA!", "SAI DA FRENTE!", "LÁ ELE!", "RECEBA", "QUÊ?", "JO!"]
#			mostrar_mensagem_encantada(frases.pick_random())

func _process(delta):
	if efeito_ativo:
		hue_timer += delta * 2.0
		modulate = Color.from_hsv(fmod(hue_timer, 1.0), 0.8, 1.0)

func mostrar_mensagem_random():
	var frases = ["VC EH CHAD", "BETINHA?", "SKILL ISSUE", "QUE AUDACIA!", "SAI DA FRENTE!", "LA ELE!", "RECEBA", "QUE?", "JO!","MOGGOU ELES", "LUCROU NA BET", "RESENHOU", "AII TOMA", "QUE OTA?", "HA?", "BURGER", "VISH", "CALMA PAI", "APELAO", "TOME", "CAVALO"]
	mostrar_mensagem_encantada(frases.pick_random())

func mostrar_mensagem_encantada(texto: String):
	text = texto
	scale = Vector2(0.5, 0.5)
	pivot_offset = size / 2
	modulate.a = 0.0
	
	efeito_ativo = true
	
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(self, "modulate:a", 1.0, 0.3)
	tween_in.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK)
	
	var tween_pulse = create_tween().set_loops()
	tween_pulse.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	tween_pulse.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)

	await get_tree().create_timer(3.0).timeout
	
	efeito_ativo = false
	tween_pulse.kill()
	
	var tween_out = create_tween().set_parallel(true)
	tween_out.tween_property(self, "modulate:a", 0.0, 0.5)
	tween_out.tween_property(self, "scale", Vector2(2.0, 2.0), 0.5)
>>>>>>> 997534200d523731e42b2db30480304b250cb4f5
