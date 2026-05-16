extends RigidBody3D

@onready var bonk_stream = $bonk
@onready var goofy_bonk_stream = $goofy_bonk
var contact = 0

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	print("SAVUBU BATEU EM: ", body.name)
	
	if contact == 0:
		contact = 1
		
		var sons = [bonk_stream]
		var som_escolhido = sons.pick_random()

		if som_escolhido:
			som_escolhido.pitch_scale = randf_range(0.95, 1.05)
			som_escolhido.play()
		
		# Teste de Depuração
		var todos_no_grupo = get_tree().get_nodes_in_group("player")
		print("Tamanho do grupo player: ", todos_no_grupo.size())
		
		if todos_no_grupo.size() > 0:
			var p = todos_no_grupo[0]
			if p.has_method("vision_shake"):
				p.vision_shake(0.1)
			else:
				print("ERRO: O nó está no grupo, mas não tem a função aplicar_tremor!")
		else:
			print("ERRO: Nenhum nó encontrado no grupo 'player'. Verifique as abas de Group do Player!")
		if body.is_in_group("enemies"):
			if body.has_method("tomar_dano"):
				body.tomar_dano("savubu")
		visible = false
		$CollisionShape3D.set_deferred("disabled", true)
		await get_tree().create_timer(1.0).timeout
		queue_free()
