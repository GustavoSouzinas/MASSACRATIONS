extends RigidBody3D

@export var EXPLOSION_RADIUS = 6.0
@export var explosao_scene: PackedScene
@onready var kaboom_stream = $kaboom
var kaboom = load("res://assets/audios/kaboom.mp3")
var contact = 0

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	kaboom_stream.stream = kaboom
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	print("SAVUBU BATEU EM: ", body.name)
	
	if contact == 0:
		contact = 1
		
		if kaboom_stream:
			kaboom_stream.play()
		
		explodir()
		
		# Teste de Depuração
		var todos_no_grupo = get_tree().get_nodes_in_group("player")
		print("Tamanho do grupo player: ", todos_no_grupo.size())
		
		if todos_no_grupo.size() > 0:
			var p = todos_no_grupo[0]
			if p.has_method("vision_shake"):
				p.vision_shake(3.0)
			else:
				print("ERRO: O nó está no grupo, mas não tem a função aplicar_tremor!")
		else:
			print("ERRO: Nenhum nó encontrado no grupo 'player'. Verifique as abas de Group do Player!")
		
			
		visible = false
		$CollisionShape3D.set_deferred("disabled", true)
		await get_tree().create_timer(1.0).timeout
		queue_free()

func explodir():

	# visual
	if explosao_scene:
		var explosao = explosao_scene.instantiate()
		get_tree().current_scene.add_child(explosao)
		explosao.global_position = global_position

	# dano
	var enemies = get_tree().get_nodes_in_group("enemies")

	for e in enemies:

		if not is_instance_valid(e):
			continue

		var dist = global_position.distance_to(e.global_position)

		if dist <= EXPLOSION_RADIUS:

			if e.has_method("tomar_dano"):
				e.tomar_dano("explosao")
