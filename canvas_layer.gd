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
	var frases = ["VC É CHAD", "BETINHA?", "SKILL ISSUE", "QUE AUDÁCIA!", "SAI DA FRENTE!", "LÁ ELE!", "RECEBA", "QUÊ?", "JO!"]
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
