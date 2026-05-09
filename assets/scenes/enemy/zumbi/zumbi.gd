extends CharacterBody3D

@export var SPEED = 5.0
@export var ATTACK_RANGE = 2.0
@export var DAMAGE = 10
@export var ATTACK_COOLDOWN = 1.0

@onready var splash = $"../gui/splash"
@onready var aura = $"../gui/aura"

# Áudio
@onready var audio = $Naotemaura
@export var min_time := 3.0
@export var max_time := 10.0

var player = null
var can_attack = true

# knockback system
var knockback_velocity = Vector3.ZERO
var knockback_time = 0.0

func _ready():
	add_to_group("enemies")

	var jogadores = get_tree().get_nodes_in_group("player")
	if jogadores.size() > 0:
		player = jogadores[0]

	play_random_loop()


# MOVIMENTO / IA

func _physics_process(delta: float) -> void:

	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = -1.0

	# KNOCKBACK COM PRIORIDADE TOTAL
	if knockback_time > 0:
		velocity = knockback_velocity
		knockback_time -= delta
		move_and_slide()
		return

	# IA NORMAL
	if player:
		var dist = global_position.distance_to(player.global_position)

		if dist > ATTACK_RANGE:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0
			velocity.z = 0
			atacar_player()

		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))

	move_and_slide()

# -----------------------------
# ATAQUE
# -----------------------------
func atacar_player():
	if can_attack and player and player.has_method("tomar_dano"):
		player.tomar_dano(DAMAGE)

		can_attack = false
		await get_tree().create_timer(ATTACK_COOLDOWN).timeout
		can_attack = true

# -----------------------------
# KNOCKBACK EXTERNO (CUMBUCA)
# -----------------------------
func aplicar_knockback(dir: Vector3, force: float):
	knockback_velocity = dir.normalized() * force
	knockback_velocity.y = 6.5  # leve lift pra sensação de impacto
	knockback_time = 0.2

# -----------------------------
# ÁUDIO ALEATÓRIO
# -----------------------------
func play_random_loop():
	while true:
		var wait_time = randf_range(min_time, max_time)
		await get_tree().create_timer(wait_time).timeout

		if is_instance_valid(audio):
			audio.play()
			audio.unit_size = 4



# -----------------------------
# MORTE
# -----------------------------
func tomar_dano(tipo):
	if tipo == "savubu":
	
		die()
	
func die():
	splash.mostrar_mensagem_random()
	aura.adicionar_combo(5)
	queue_free()
