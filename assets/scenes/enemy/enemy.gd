extends CharacterBody3D

@export var SPEED = 5.0
@export var ATTACK_RANGE = 2.0 # Distância para o ataque
@export var DAMAGE = 10        # Quanto de vida ele tira
@export var ATTACK_COOLDOWN = 1.0 # Tempo entre um tapa e outro

# Áudio
@onready var audio = $Naotemaura
@export var min_time := 3.0
@export var max_time := 10.0

var player = null
var can_attack = true # Controla o tempo de recarga do ataque

func _ready():
	add_to_group("enemies")
	var jogadores = get_tree().get_nodes_in_group("player")
	if jogadores.size() > 0:
		player = jogadores[0]
	
	play_random_loop()

func _physics_process(delta: float) -> void:
	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = -1.0

	if player:
		var dist = global_position.distance_to(player.global_position)
		
		# Se estiver longe, persegue
		if dist > ATTACK_RANGE:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			# Se estiver perto, para e tenta atacar
			velocity.x = 0
			velocity.z = 0
			atacar_player()
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))

	move_and_slide()

func atacar_player():
	if can_attack and player.has_method("tomar_dano"):
		player.tomar_dano(DAMAGE)
		
		# Inicia o tempo de espera para o próximo ataque
		can_attack = false
		await get_tree().create_timer(ATTACK_COOLDOWN).timeout
		can_attack = true

# Loop de áudio aleatório
func play_random_loop():
	while true:
		var wait_time = randf_range(min_time, max_time)
		await get_tree().create_timer(wait_time).timeout
		
		if is_instance_valid(audio): # Segurança para não dar erro ao morrer
			audio.play()
			audio.unit_size = 4

func die():
	queue_free()
