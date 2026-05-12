extends CharacterBody3D

@export var SPEED = 14.0
@export var CHARGE_SPEED = 35.0
@export var ATTACK_RANGE = 2.0
@export var DETECT_RANGE = 20.0
@export var DAMAGE = 10
@export var ATTACK_COOLDOWN = 1.0
@export var CHARGE_DURATION = 0.7
# tempo tremendo antes do ataque
@export var CHARGE_PREPARE_TIME = 0.4

@onready var splash = $"../gui/splash"
@onready var aura = $"../gui/aura"
@onready var node_player = $"../player"

# Áudio
@onready var audio = $Naotemaura
@onready var moto_rev = $motoacelera
@export var min_time := 3.0
@export var max_time := 10.0

var player = null
var can_attack = true
var charge_timer = 0.0


# knockback system
var knockback_velocity = Vector3.ZERO
var knockback_time = 0.0

# -----------------------------
# IA
# -----------------------------

enum {
	RONDA,
	PREPARANDO_ATAQUE,
	ATACANDO
}

var estado = RONDA

var attack_timer = 0.0
var charge_direction = Vector3.ZERO

# tremedeira
var shake_power = 0.12
var original_position = Vector3.ZERO

func _ready():
	add_to_group("enemies")

	var jogadores = get_tree().get_nodes_in_group("player")
	if jogadores.size() > 0:
		player = jogadores[0]

	play_random_loop()

	original_position = global_position


# -----------------------------
# MOVIMENTO / IA
# -----------------------------

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

	if player:

		var dist = global_position.distance_to(player.global_position)

		match estado:

			# -----------------------------
			# RONDANDO
			# -----------------------------
			RONDA:

				if dist > ATTACK_RANGE:

					var direction = (player.global_position - global_position).normalized()
					

					velocity.x = direction.x * SPEED
					velocity.z = direction.z * SPEED
					
					look_at(global_position + direction)
				else:
					velocity.x = 0
					velocity.z = 0

				# começou ataque
				if dist <= DETECT_RANGE:

					estado = PREPARANDO_ATAQUE
					attack_timer = CHARGE_PREPARE_TIME

					

					charge_direction = (
						Vector3(
						player.global_position.x,
						global_position.y,
						player.global_position.z
						) - global_position
					).normalized()


			# -----------------------------
			# TREMER ANTES DA INVESTIDA
			# -----------------------------
			PREPARANDO_ATAQUE:

				velocity.x = 0
				velocity.z = 0

				attack_timer -= delta

				# tremedeira
				global_position.x += randf_range(-shake_power, shake_power)
				global_position.z += randf_range(-shake_power, shake_power)

				look_at(global_position + charge_direction)

				if attack_timer <= 0:
					estado = ATACANDO
					charge_timer = CHARGE_DURATION
					moto_rev.play()
					moto_rev.unit_size = 4


			# -----------------------------
			# INVESTIDA RETA
			# -----------------------------
			ATACANDO:

				velocity.x = charge_direction.x * CHARGE_SPEED
				velocity.z = charge_direction.z * CHARGE_SPEED

				look_at(global_position + charge_direction)

				# bateu no player
				if dist <= ATTACK_RANGE:
					atacar_player()
				
				charge_timer -= delta

				if charge_timer <= 0:
					estado = RONDA
				# passou do alvo
				

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
# KNOCKBACK EXTERNO
# -----------------------------
func aplicar_knockback(dir: Vector3, force: float):

	knockback_velocity = dir.normalized() * force
	knockback_velocity.y = 6.5
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
	node_player.ganhar_bateria(1)

	queue_free()
