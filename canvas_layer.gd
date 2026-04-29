extends CanvasLayer

@onready var label_mensagem = $Mensagem

var efeito_ativo = false
var hue_timer = 0.0

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_F and event.pressed:
			var frases = ["VC É CHAD", "BETINHA?", "SKILL ISSUE", "QUE AUDÁCIA!", "SAI DA FRENTE!"]
			mostrar_mensagem_encantada(frases.pick_random())

func _process(delta):
	# Se a mensagem estiver na tela, faz o ciclo de cores (Rainbow)
	if efeito_ativo:
		hue_timer += delta * 2.0 # Velocidade da troca de cor
		# Cria uma cor baseada no tempo (H, S, V)
		# fmod garante que o valor fique entre 0 e 1
		label_mensagem.modulate = Color.from_hsv(fmod(hue_timer, 1.0), 0.8, 1.0)

func mostrar_mensagem_encantada(texto: String):
	label_mensagem.text = texto
	label_mensagem.scale = Vector2(0.5, 0.5)
	label_mensagem.pivot_offset = label_mensagem.size / 2
	label_mensagem.modulate.a = 0.0
	
	efeito_ativo = true # Liga o ciclo de cores no _process
	
	# 1. Aparecer com impacto (Pop-in)
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(label_mensagem, "modulate:a", 1.0, 0.3)
	tween_in.tween_property(label_mensagem, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK)
	
	# 2. Pulsação leve (além das cores)
	var tween_pulse = create_tween().set_loops().set_parallel(true)
	tween_pulse.tween_property(label_mensagem, "scale", Vector2(1.1, 1.1), 0.5)
	tween_pulse.chain().tween_property(label_mensagem, "scale", Vector2(1.2, 1.2), 0.5)

	# 3. Espera 3 segundos e some
	await get_tree().create_timer(3.0).timeout
	
	# Finaliza
	efeito_ativo = false # Para o arco-íris
	tween_pulse.kill()
	
	var tween_out = create_tween().set_parallel(true)
	tween_out.tween_property(label_mensagem, "modulate:a", 0.0, 0.5)
	tween_out.tween_property(label_mensagem, "scale", Vector2(2.0, 2.0), 0.5) # Explode ao sumir
