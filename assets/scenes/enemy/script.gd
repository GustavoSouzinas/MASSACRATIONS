extends CharacterBody3D

@export var SPEED = 12.0 # Velocidade aumentada (era 4.0)
@export var ATTACK_RANGE = 1.5
@export var ACCEL = 10.0 # Quão rápido ele atinge a velocidade máxima

var player = null

func _ready():
	add_to_group("enemies")
	# Busca o jogador
	var jogadores = get_tree().get_nodes_in_group("player")
	if jogadores.size() > 0:
		player = jogadores[0]

func _physics_process(delta: float) -> void:
	# GRAVIDADE: Força o inimigo para baixo sempre
	if not is_on_floor():
		velocity.y -= 25.0 * delta # Valor alto para ele não flutuar
	else:
		velocity.y = -1.0 # "Cola" ele no chão para detectar degraus

	if player:
		# Move em direção ao player, mas preserva a velocidade Y (gravidade)
		var direction = (player.global_position - global_position).normalized()
		
		# IMPORTANTE: Não mexa no velocity.y aqui! 
		# Só alteramos X e Z para ele andar
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))

	# move_and_slide usa a velocity que calculamos acima
	move_and_slide()
