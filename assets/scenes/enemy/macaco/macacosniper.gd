extends CharacterBody3D

@onready var anim = $"Run Forward (2)/AnimationPlayer"

@onready var node_player = $"../player"
@onready var splash = $"../gui/splash"
@onready var aura = $"../gui/aura"
@onready var streak = $"../gui/Control"
@onready var shoot_audio = $atiramacaco
@export var shoot_sound: AudioStream
@export var ragdoll_scene: PackedScene

@export var SPEED = 4.0



# Distâncias tipo sentry
@export var MIN_DISTANCE = 6.0   # muito perto → recua
@export var MAX_DISTANCE = 16.0  # muito longe → aproxima

@export var SHOOT_COOLDOWN = 1.0
static var proximo_tiro_em := 0.0

# projétil
@export var bullet_scene: PackedScene
@export var BULLET_SPEED = 36.0

# Áudio
@onready var audio = $Naotemaura
@export var min_time := 3.0
@export var max_time := 10.0

var is_moving := false
var player = null
var can_shoot = true

# knockback
var knockback_velocity = Vector3.ZERO
var knockback_time = 0.0


func _ready():
	add_to_group("enemies")

	var jogadores = get_tree().get_nodes_in_group("player")
	if jogadores.size() > 0:
		player = jogadores[0]

	play_random_loop()


func _physics_process(delta):

	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = -1.0

	# KNOCKBACK PRIORIDADE
	if knockback_time > 0:
		velocity = knockback_velocity
		knockback_time -= delta
		move_and_slide()
		return

	if player:
		var dist = global_position.distance_to(player.global_position)

		# -------------------------
		# COMPORTAMENTO SNIPER
		# -------------------------

		var direction = (player.global_position - global_position).normalized()

		if dist > MAX_DISTANCE:
			# muito longe → aproxima
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

		elif dist < MIN_DISTANCE:
			# muito perto → recua
			velocity.x = -direction.x * SPEED
			velocity.z = -direction.z * SPEED

		else:
			# distância ideal → para e atira
			velocity.x = 0
			velocity.z = 0
			atirar()

		# sempre olha pro player
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))

	move_and_slide()
	update_animation()


# -----------------------------
# TIRO SNIPER
# -----------------------------
func atirar():
	if not can_shoot or not bullet_scene:
		return
		
	var agora = Time.get_ticks_msec() / 1000.0

	if agora < proximo_tiro_em:
		return

	# reserva o próximo slot de tiro
	proximo_tiro_em = agora + 0.6

	can_shoot = false

	shoot_audio.stream = load("res://assets/audios/macaco.mp3")
	shoot_audio.play()


	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	# posição inicial (um pouco na frente)
	var spawn_pos = global_position + (-global_transform.basis.z * 1.5) + Vector3(0, 0.7, 0) # altura
	bullet.global_position = spawn_pos

	# direção
	var target_pos = player.global_position + Vector3(0, 0.8, 0)

	var player_vel = Vector3(
		player.velocity.x,
		0,
		player.velocity.z
	)

	var dist = spawn_pos.distance_to(target_pos)
	var tempo_de_voo = dist / BULLET_SPEED

	var predicted_pos = target_pos + player_vel * tempo_de_voo

	# 100% predictive até 8m
	# 0% predictive a partir de 12m
	var predictive_strength = 1.0 - clamp(
		(dist - 8.0) / (15.0 - 8.0),
		0.0,
		1.0
	)

	var final_target = target_pos.lerp(
		predicted_pos,
		predictive_strength
	)

	var dir = (final_target - spawn_pos).normalized()

	# aplica velocidade (depende do script da bala, é mentira)
	if bullet.has_method("set_velocity"):
		bullet.set_velocity(dir * BULLET_SPEED)

	# fallback se for rigidbody
	if bullet is RigidBody3D:
		bullet.linear_velocity = dir * BULLET_SPEED

	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	can_shoot = true


# -----------------------------
# KNOCKBACK
# -----------------------------
func aplicar_knockback(dir: Vector3, force: float):
	knockback_velocity = dir.normalized() * force
	knockback_velocity.y = 6.5
	knockback_time = 0.2


# -----------------------------
# ÁUDIO
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
var morto = false
func tomar_dano(tipo):
	if tipo == "savubu":
		return #imune
		
	if tipo == "explosao":
	
		die()
	die()

func die():

	if morto:
		return

	morto = true

	var saved_pos = global_position
	var saved_rot = global_rotation

	# Direção: empurra pra longe do player
	var direcao = (
		global_position - player.global_position
	).normalized()

	splash.mostrar_mensagem_random()
	aura.adicionar_combo(5)
	node_player.ganhar_bateria(1)
	streak.registrar_kill()

	if ragdoll_scene:
		var ragdoll = ragdoll_scene.instantiate()
		get_tree().current_scene.add_child(ragdoll)
		ragdoll.iniciar(saved_pos, saved_rot, direcao)
	else:
		push_error("ragdoll_scene não atribuído: " + name)

	queue_free()

#animação

func update_animation():
	var horizontal_speed = Vector3(velocity.x, 0, velocity.z).length()

	if horizontal_speed > 0.1:
		if not is_moving:
			anim.play("mixamo_com")
			is_moving = true
	else:
		if is_moving:
			anim.pause() 
			is_moving = false
