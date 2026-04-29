extends CharacterBody3D

@onready var camera = $vision
@onready var gun_stream = $gun_audio
@onready var walk_stream = $walk_audio

var mouse_relative_x = 0.0
var mouse_relative_y = 0.0
var camera_rot_x = 0.0

var savubu_prop = preload("res://assets/scenes/savubu/savubu_prop.tscn")

var SPEED = 17
const ACCEL = .75
const JUMP_VELOCITY = 4.5

var step1 = preload("res://assets/audios/step1.mp3")
var crowbar = preload("res://assets/audios/hl_crowbar.mp3")	

var step_timer = 0.0
var shake_intensity = 0.0

func vision_shake(forca: float):
	shake_intensity = forca 

func _ready():
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func play_audio(stream: AudioStreamPlayer3D, audio: AudioStream):
	if stream:
		stream.stream = audio
		stream.pitch_scale = randf_range(0.9, 1.1) 
		stream.play()
	else:
		return

func gerar_personagem():
	var novo_corpo = savubu_prop.instantiate()
	get_parent().add_child(novo_corpo)
	
	# Define posição E rotação baseadas na câmera
	novo_corpo.global_position = camera.global_position + (-camera.global_transform.basis.z * 1.5)
	novo_corpo.global_rotation = camera.global_rotation # Faz o objeto "olhar" para onde você olha
	
	if novo_corpo is RigidBody3D:
		var direcao_tiro = -camera.global_transform.basis.z
		novo_corpo.apply_central_impulse(direcao_tiro * 25.0)
		
		# Opcional: Adiciona um torque para o objeto girar enquanto voa
		novo_corpo.apply_torque_impulse(Vector3(randf(), randf(), randf()) * 5.0)
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			if event.pressed and is_on_floor():
				SPEED = 17.0 / 3.0
			else:
				SPEED = 17
				
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			play_audio(gun_stream, crowbar)
			gerar_personagem()
				
	if event is InputEventMouseMotion:
		rotate_y(event.relative.x * -0.002)
		
		camera_rot_x -= event.relative.y * 0.002
		camera_rot_x = clamp(camera_rot_x, -deg_to_rad(85), deg_to_rad(85)) # 85 graus é mais seguro que PI/2
		
		camera.rotation.x = camera_rot_x

func _process(delta: float) -> void:
	
	if shake_intensity > 0:
		camera.h_offset = randf_range(-1.0, 1.0) * shake_intensity
		camera.v_offset = randf_range(-1.0, 1.0) * shake_intensity
		
		# Opcional: Rotaciona levemente para um efeito mais caótico
		camera.rotation.z = randf_range(-0.05, 0.05) * shake_intensity
		
		shake_intensity = move_toward(shake_intensity, 0.0, delta * 5.0)
	else:
		# Reseta a câmera para a posição normal quando o tremor acaba
		camera.h_offset = 0
		camera.v_offset = 0
		camera.rotation.z = 0
	
	var vel = Vector2(velocity.x, velocity.z)
	
	if vel.length() > 0.1 and is_on_floor():
		step_timer -= delta
		if step_timer <= 0:
			play_audio(walk_stream, step1)  # ← ISSO TAVA FALTANDO!
			step_timer = 0.3
	else:
		step_timer = 0  # Reseta quando para

func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Pulo
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Movimento
	var input_dir := Vector2(
		float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
		float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W)))
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL) 
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL) 
	else:
		velocity.x = move_toward(velocity.x, 0, .7)
		velocity.z = move_toward(velocity.z, 0, .7)
	
	move_and_slide()
