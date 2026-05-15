extends CharacterBody3D

@export var SPEED = 15.0
@export var ATTACK_RANGE = 2.0
@export var DAMAGE = 20
@export var ATTACK_COOLDOWN = 5.0
@export var ragdoll_scene: PackedScene

# TEMPO até trocar pra pose parada
@export var stop_pose_delay := 0.25

@onready var splash = $"../gui/splash"
@onready var aura = $"../gui/aura"
@onready var node_player = $"../player"
@onready var streak = $"../gui/Control"

# POSES
@onready var andando = $"Clapping (1)"
@onready var parado = $"CRIAmodel2"

# ÁUDIOS
@onready var palmas = $palmas
@onready var asminaae = $asminaae
@onready var tchetche = $tchetche

var ultimo_estado := false
var vulneravel := false

var player = null
var can_attack = true

# knockback system
var knockback_velocity = Vector3.ZERO
var knockback_time = 0.0

# weeping angel
var sendo_olhado := false
var trocando_pose := false

func _ready():
	add_to_group("enemies")
	palmas.stream.loop = true
	var jogadores = get_tree().get_nodes_in_group("player")
	if jogadores.size() > 0:
		player = jogadores[0]



	# começa parado
	andando.visible = false
	parado.visible = true


# =====================================================
# MOVIMENTO / IA
# =====================================================

func _physics_process(delta: float) -> void:

	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = -1.0

	# KNOCKBACK
	if knockback_time > 0:
		velocity = knockback_velocity
		knockback_time -= delta
		move_and_slide()
		return

	if player:

		# verifica se player está olhando
		sendo_olhado = player_esta_olhando()

		var dist = global_position.distance_to(player.global_position)

		# SEMPRE olha pro player
		look_at(
			Vector3(
				player.global_position.x,
				global_position.y,
				player.global_position.z
			)
		)

		# =========================================
		# SENDO OLHADO = CONGELADO
		# =========================================
		if sendo_olhado:

			velocity.x = 0
			velocity.z = 0

			trocar_para_parado()

		# =========================================
		# NÃO ESTÁ SENDO OLHADO = PERSEGUE
		# =========================================
		else:

			trocar_para_andando()

			if dist > ATTACK_RANGE:
				var direction = (
					player.global_position - global_position
				).normalized()

				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = 0
				velocity.z = 0
				atacar_player()

	atualizar_audio()

	move_and_slide()


# =====================================================
# DETECTAR SE O PLAYER ESTÁ OLHANDO
# =====================================================

func player_esta_olhando() -> bool:

	var camera = get_viewport().get_camera_3d()

	if camera == null:
		return false

	# direção da câmera
	var camera_forward = -camera.global_transform.basis.z.normalized()

	# direção da câmera até o inimigo
	var dir_to_enemy = (
		global_position - camera.global_position
	).normalized()

	# ângulo de visão
	var dot = camera_forward.dot(dir_to_enemy)

	# se estiver na frente da câmera
	if dot > 0.75:

		# raycast pra garantir que não tem parede
		var space_state = get_world_3d().direct_space_state

		var query = PhysicsRayQueryParameters3D.create(
			camera.global_position,
			global_position
		)

		query.exclude = [camera]

		var result = space_state.intersect_ray(query)

		# se bateu direto no inimigo
		if result:
			if result.collider == self:
				return true

	return false


# =====================================================
# TROCA DE POSES
# =====================================================

func trocar_para_andando():

	if andando.visible:
		return

	vulneravel = true

	andando.visible = true
	parado.visible = false


func trocar_para_parado():

	if parado.visible or trocando_pose:
		return

	trocando_pose = true

	# delayzinho creepy
	await get_tree().create_timer(stop_pose_delay).timeout

	if sendo_olhado:

		andando.visible = false
		parado.visible = true

		# AGORA pode tomar dano
		vulneravel = false

	trocando_pose = false


# =====================================================
# ATAQUE
# =====================================================

func atacar_player():
	if can_attack and player and player.has_method("tomar_dano"):
		player.tomar_dano(DAMAGE)

		can_attack = false
		await get_tree().create_timer(ATTACK_COOLDOWN).timeout
		can_attack = true


# =====================================================
# KNOCKBACK
# =====================================================

func aplicar_knockback(dir: Vector3, force: float):
	knockback_velocity = dir.normalized() * force
	knockback_velocity.y = 6.5
	knockback_time = 0.2


# =====================================================
# ÁUDIO
# =====================================================



# =====================================================
# MORTE
# =====================================================

var morto = false

func tomar_dano(tipo):

	# explosão sempre mata
	if tipo == "explosao":
		die()
		return

	# savubu só mata enquanto ele está perseguindo
	if tipo == "savubu":

		if not vulneravel:
			return

		die()

	


func die():

	if morto:
		return

	morto = true

	var saved_pos = global_position
	var saved_rot = global_rotation

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


# =====================================================
# ÁUDIO WEEPING ANGEL
# =====================================================

func atualizar_audio():

	# =========================================
	# SENDO OLHADO
	# =========================================
	if sendo_olhado:

		# para loop de perseguição
		if palmas.playing:
			palmas.stop()

		# toca asminaae aleatoriamente
		if not asminaae.playing:
			if randf() < 0.001:
				asminaae.play()

	# =========================================
	# PERSEGUINDO
	# =========================================
	else:

		# loop de palmas
		if not palmas.playing:
			palmas.play()

		# tchetche aleatório
		if not tchetche.playing:
			if randf() < 0.002:
				tchetche.play()
