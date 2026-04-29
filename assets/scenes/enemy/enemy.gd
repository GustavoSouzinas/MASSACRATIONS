extends CharacterBody3D

@export var SPEED = 5.0
@export var ATTACK_RANGE = 1.5
@export var ACCEL = 10.0

# Áudio
@onready var audio = $Naotemaura
@export var min_time := 3.0
@export var max_time := 10.0

var player = null

func _ready():
	add_to_group("enemies")
	
	# Busca o jogador
	var jogadores = get_tree().get_nodes_in_group("player")
	if jogadores.size() > 0:
		player = jogadores[0]
	
	# inicia loop de som
	play_random_loop()

func _physics_process(delta: float) -> void:
	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = -1.0

	if player:
		var direction = (player.global_position - global_position).normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))

	move_and_slide()

# Loop de áudio aleatório
func play_random_loop():
	while true:
		var wait_time = randf_range(min_time, max_time)
		await get_tree().create_timer(wait_time).timeout
		
		if audio:
			audio.play()
			audio.unit_size = 4

func die():
	queue_free()
