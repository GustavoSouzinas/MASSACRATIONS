extends Label

var vida_exibida : int = 100

func _ready() -> void:
	# Centraliza o pivot para a animação de escala (crescer do meio)
	self.pivot_offset = self.size / 2
	
	# Procura o player e conecta o sinal
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vida_alterada.connect(_ao_mudar_vida)
		vida_exibida = player.vida
		self.text = str(vida_exibida)

func _ao_mudar_vida(nova_vida: int):
	# 1. Animação do número "contando" até o valor novo
	var tween_num = create_tween()
	tween_num.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_num.tween_method(_atualizar_texto, vida_exibida, nova_vida, 0.5)
	
	vida_exibida = nova_vida
	
	# 2. Efeito visual de impacto (Cresce e fica Vermelho)
	var tween_visual = create_tween().set_parallel(true)
	self.modulate = Color.RED
	self.scale = Vector2(1.5, 1.5) # Aumenta 50%
	
	# Volta ao normal
	tween_visual.tween_property(self, "modulate", Color.WHITE, 0.5)
	tween_visual.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK)
	
	# 3. Tremedeira (Shake)
	_tremer(0.4)

func _atualizar_texto(valor):
	self.text = str(int(valor))

func _tremer(duracao):
	var pos_original = self.position
	var tempo = 0.0
	while tempo < duracao:
		var offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		self.position = pos_original + offset
		await get_tree().process_frame
		tempo += get_process_delta_time()
	self.position = pos_original
