extends CharacterBody3D

# --- NÓS ---
@onready var anim = $vision/AnimatedSprite3D
@onready var camera = $vision
@onready var gun_stream = $gun_audio
@onready var walk_stream = $walk_audio
@onready var dano_stream = $dano
@onready var aura = $"../gui/aura"
@onready var cura_efeito = $"../gui/cura_vinheta"
@onready var dano_efeito = $"../gui/dano_vinheta"


enum aparato_de_ataque {
	SAVUBU,
	CUMBUCA
}

var aparato_atual = aparato_de_ataque.SAVUBU

var ammo = {
	aparato_de_ataque.SAVUBU: 5,
	aparato_de_ataque.CUMBUCA: 20
}

var ammo_max = {
	aparato_de_ataque.SAVUBU: 5,
	aparato_de_ataque.CUMBUCA: 20
}

func adicionar_municao(arma, quantidade):
	ammo[arma] = clamp(ammo[arma] + quantidade, 0, ammo_max[arma])

const BOB_FREQ = 1.8
const BOB_AMP = 0.05

var t_bob = 0.0
var camera_origin_base = Vector3.ZERO
var camera_rotation_base = Vector3.ZERO
var spawn_transform = Transform3D.IDENTITY

var vida_max := 100
var _vida := 100
var vida:
	get:
		return _vida
	set(value):
		_vida = clamp(value, 0, vida_max)
		vida_alterada.emit(_vida)
		if _vida <= 0 and not morto:
# --- STATUS ---
var vida_maxima = 100
# --- SISTEMA DE CURA (CELULAR) ---
var bateria = 0
var bateria_max = 10

func ganhar_bateria(valor := 1):
	var ganho = valor * get_multiplicador_cortisol()
	bateria = clamp(bateria + ganho, 0, bateria_max)
	
var curando = false
	
func usar_celular_cura():

	#print("tentou curar")

	if bateria < bateria_max:
		#print("sem bateria")
		return

	if curando:
		#print("já curando")
		return

	curando = true
	
	anim.play("scroll")

	await anim.tocar_animacao_unica("scroll")

	if morto: return

	vida += 25 * get_multiplicador_cortisol()
	cura_efeito.tocar()
	vida = clamp(vida, 0, vida_maxima)

	bateria = 0

	curando = false

var vida = vida_maxima:
	set(valor):
		vida = clamp(valor, 0, vida_maxima)
		vida_alterada.emit(vida)
		if vida <= 0 and not morto:
			morrer()

var cortisol = 0.0
var cortisol_max = 10.0
var morto = false

signal vida_alterada(valor)
signal aura_alterada(valor)

var SPEED = 17.0
const ACCEL = 0.75
const JUMP_VELOCITY = 4.5
var camera_rot_x = 0.0

var farofa_prop = preload("res://assets/scenes/cumbuca/farofa_particle.tscn")
var savubu_prop = preload("res://assets/scenes/savubu/savubu_prop.tscn")
var step1 = preload("res://assets/audios/step1.mp3")
var crowbar = preload("res://assets/audios/hl_crowbar.mp3")
var cough = preload("res://assets/audios/cough.mp3")
var sound_dead = preload("res://assets/scenes/player/audio/dead.mp3")

var step_timer = 0.0
var shake_intensity = 0.0
var shake_decay = 5.0

func _ready():
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	spawn_transform = global_transform
	camera_origin_base = camera.position
	camera_rotation_base = camera.rotation

	vida_alterada.emit(vida)
	aura_alterada.emit(aura)

func resetar():
	morto = false
	vida = vida_max
	cortisol = 0.0
	velocity = Vector3.ZERO

	global_transform = spawn_transform
	camera.position = camera_origin_base
	camera.rotation = camera_rotation_base
	camera_rot_x = camera_rotation_base.x

	t_bob = 0.0
	step_timer = 0.0
	shake_intensity = 0.0
	shake_decay = 5.0

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	ammo[aparato_de_ataque.SAVUBU] = ammo_max[aparato_de_ataque.SAVUBU]
	ammo[aparato_de_ataque.CUMBUCA] = ammo_max[aparato_de_ataque.CUMBUCA]

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R and morto:
		resetar()
		return

	if morto:
		return

	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_C:
			usar_celular_cura()

	# Alternar Mouse (ESC)
	if event is InputEventKey and event.is_action_pressed("ui_cancel"): # Recomendado usar Actions
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

	if event is InputEventKey and event.keycode == KEY_SHIFT:
		SPEED = (17.0 / 3.0) if event.pressed else 17.0

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if curando:
			return
		
		if ammo[aparato_atual] <= 0:
			print("sem munição")
			return

		match aparato_atual:
			aparato_de_ataque.SAVUBU:
				savubu_shoot()
			aparato_de_ataque.CUMBUCA:
				cumbuca_shoot()

		ammo[aparato_atual] -= 1

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			aparato_atual = aparato_de_ataque.SAVUBU
		elif event.keycode == KEY_2:
			aparato_atual = aparato_de_ataque.CUMBUCA

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(event.relative.x * -0.002)
		camera_rot_x -= event.relative.y * 0.002
		camera_rot_x = clamp(camera_rot_x, -deg_to_rad(85), deg_to_rad(85))
		camera.rotation.x = camera_rot_x

func _process(delta: float) -> void:
	if not morto and is_on_floor() and velocity.length() > 0.1:
		t_bob += delta * velocity.length()

		var bob_pos = Vector3.ZERO
		bob_pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		bob_pos.x = cos(t_bob * BOB_FREQ / 2.0) * BOB_AMP
		camera.position = camera_origin_base + bob_pos

		step_timer -= delta
		if step_timer <= 0.0:
			play_audio(walk_stream, step1)
			step_timer = 0.35
	else:
		t_bob = 0.0
		camera.position = camera.position.lerp(camera_origin_base, delta * 10.0)
		step_timer = 0.0

	calcular_cortisol()

	if shake_intensity > 0.0:
		camera.h_offset = randf_range(-1.0, 1.0) * shake_intensity
		camera.v_offset = randf_range(-1.0, 1.0) * shake_intensity
		camera.rotation.z = randf_range(-0.05, 0.05) * shake_intensity
		shake_intensity = move_toward(shake_intensity, 0.0, delta * shake_decay)
	elif not morto:
		camera.h_offset = 0.0
		camera.v_offset = 0.0
		camera.rotation.z = move_toward(camera.rotation.z, 0.0, delta)

func _physics_process(delta: float) -> void:
	if morto:
		velocity = velocity.move_toward(Vector3.ZERO, 0.5)
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir == Vector2.ZERO:
		input_dir = Vector2(
			float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
			float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
		)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 0.7)
		velocity.z = move_toward(velocity.z, 0.0, 0.7)

	move_and_slide()

func tomar_dano(quantidade):
	if morto:
		return

	vida -= quantidade

	if dano_stream:
		dano_stream.pitch_scale = randf_range(0.9, 1.1)
		dano_stream.play()

	vision_shake(0.4, 0.8)
	dano_efeito.tocar()

func morrer():
	morto = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if dano_stream:
		dano_stream.stream = sound_dead
		dano_stream.pitch_scale = 1.0
		dano_stream.play()

	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "rotation:z", deg_to_rad(45), 1.0)
	tween.tween_property(camera, "position:y", -1.2, 0.6)

func vision_shake(forca: float, tempo: float = 0.5):
	shake_intensity = forca
	shake_decay = (forca / tempo) if tempo > 0.0 else 10.0

func play_audio(stream: AudioStreamPlayer3D, audio: AudioStream):
	if stream:
		stream.stream = audio
		stream.pitch_scale = randf_range(0.9, 1.1)
		stream.play()

func savubu_shoot():
	var novo_corpo = savubu_prop.instantiate()
	get_parent().add_child(novo_corpo)
	play_audio(gun_stream, crowbar)
	novo_corpo.global_position = camera.global_position + (-camera.global_transform.basis.z * 1.5)
	novo_corpo.global_rotation = camera.global_rotation

	if novo_corpo is RigidBody3D:
		var direcao_tiro = -camera.global_transform.basis.z
		direcao_tiro = direcao_tiro.rotated(Vector3.UP, deg_to_rad(4.5))
		novo_corpo.apply_central_impulse(direcao_tiro * 25.0)
		novo_corpo.apply_torque_impulse(Vector3(randf(), randf(), randf()) * 5.0)

func cumbuca_shoot():
	var novo_corpo = farofa_prop.instantiate()
	get_parent().add_child(novo_corpo)
	play_audio(gun_stream, cough)

	var origem = camera.global_position + (-camera.global_transform.basis.z * 1.5)
	novo_corpo.global_position = origem

	var radius = 4.0
	var parry_radius = 2.0

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is CharacterBody3D:
			var dir = enemy.global_position - origem
			var dist = dir.length()

			if dist < radius:
				dir = dir.normalized()
				var force = (3.0 - (dist / radius)) * 18.0
				enemy.aplicar_knockback(dir, force)

	for bullet in get_tree().get_nodes_in_group("enemy_bullets"):
		var dist_cumbuca = bullet.global_position.distance_to(origem)
		var dist_player = bullet.global_position.distance_to(camera.global_position)

		if dist_cumbuca < radius and dist_player < parry_radius:
			if bullet.has_method("parry"):
				bullet.parry(self)
				aura.adicionar_combo(10)
				
				

func calcular_cortisol():
	var origem = global_position
	var raio = 15.0
	var count = 0

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is CharacterBody3D:
			var dist = enemy.global_position.distance_to(origem)
			if dist < raio:
				count += 1

	cortisol = clamp(count, 0, cortisol_max)
	aura_alterada.emit(cortisol)

func get_cortisol_normalizado():
	return cortisol / cortisol_max

func get_multiplicador_cortisol():
	return 1.0 + (cortisol * 0.2)
