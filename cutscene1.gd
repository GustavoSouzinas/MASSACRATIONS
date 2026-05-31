extends Node3D

# =========================================================
# NODES
# =========================================================

@export_file("*.tscn")
var proxima_cena: String

@onready var camera_rig = $CameraRig

@onready var fade = $CanvasLayer/Fade

@onready var dialog_box = $CanvasLayer/DialogRoot/DialogBox
@onready var name_label = $CanvasLayer/DialogRoot/NameLabel
@onready var text_label = $CanvasLayer/DialogRoot/TextLabel

# =========================================================
# CONFIG
# =========================================================

@export var fade_in_duration := 1.0
@export var fade_out_duration := 0.6
@export var camera_move_duration := 0.05
@export var text_speed := 0.02

# =========================================================
# CAMERAS
# =========================================================

var cameras := {}

# =========================================================
# DIALOGOS
# =========================================================

var dialogos = [

	{
		"camera": "Cam1",
		"nome": "Charles",
		"texto": '"Mano tu viu q a virginia se separou do Vini?"'
	},

	{
		"nome": "Carlão",
		"texto": '"Vei pelo amor de Deus quem n ja sabia q isso ia acontecer"'
	},

	{
		"nome": "Carlão",
		"texto": '"O próximo é você e sua nega kkk"'
	},

	{
		"nome": "Charles",
		"texto": '"Tua cabeça"'
	},

{
		"camera": "Cam2",
		"nome": "Charles",
		"texto": '"Branquelo hj to confiante"'
	},

	{
		"nome": "Carlão",
		"texto": '"Noq?"'
	},

	{
		"nome": "Charles",
		"texto": '"Botei 100 hj, falaram q tinha bug novo e botei fé"'
	},

	{
		"nome": "Carlão",
		"texto": '"É nada"'
	},

	{
		"nome": "Charles",
		"texto": '"To falando kkk"'
	},

	{
		"nome": "Carlão",
		"texto": '"Minha tia pegou câncer com isso ai"'
	},

	{
		"nome": "Charles",
		"texto": '"Larga de ser mídia branquelo, vou é ficar rico"'
	},

	{
		"nome": "Carlão",
		"texto": '"Vai fazer oq com o dinhero?"'
	},

	{
		"nome": "Charles",
		"texto": '"Vei acho q vou ir pra dubai"'
	},

	{
		"nome": "Carlão",
		"texto": '"KKKKKKK vai achando negão"'
	},

	{
		"nome": "Charles",
		"texto": '"Duvide n que o mundo dá voltas"'
	},

	{
		"nome": "Charles",
		"texto": '"Tu vai pedir esmola é pra mim"'
	},

	{
		"nome": "Carlão",
		"texto": '"Fale isso quando tu parar de pedir dinhero a tua vó"'
	},

	{
		"nome": "Charles",
		"texto": '"Mano, é só cair e vapo, fi"'
	},

	{
		"camera": "Cam3",
		"nome": "Charles",
		"texto": '"O tanto de cara que ganha grana com isso mano"'
	},
	
	{
		"nome": "Charles",
		"texto": '"Ó o neymar aí"'
	},
	
	{
		"nome": "Charles",
		"texto": '"Aquele cabeça lá tbm q esqueci o nome"'
	},
	
	{
		"nome": "Charles",
		"texto": '"Isso que é vida"'
	},
	
	{
		"camera": "Cam2",
		"nome": "Charles",
		"texto": '"Pelo menos até eu pagar as parcela do meu tijolão"'
	},
	
	{
		"nome": "Carlão",
		"texto": '"Tu faz oq tu quiser com tua vida mano"'
	},
	
	{
		"nome": "Carlão",
		"texto": '"Só sei que isso é papo pra boi dormir"'
	},
	
	{
		"camera": "Cam1",
		"nome": "Carlão",
		"texto": '"Tu tem q ficar ligado nas coisas po"'
	},
	
	{
		"nome": "Carlão",
		"texto": '"N quero te ver um dia na rua"'
	},
	
	{
		"nome": "Carlão",
		"texto": '"Sla mano arranja alguma coisa pra tu"'
	},
	
	{
		"nome": "Charles",
		"texto": '"TU QUER QUE EU VOLTE PRO ATACADÃO?"'
	},
	
	{
		"nome": "Carlão",
		"texto": '"Não né mermao"'
	},
	
	{
		"nome": "Charles",
		"texto": '"N vem com ideia errada não, que eu vou ganha esse dinheiro e cabô, fim de papo."'
	},
	
	{
		"camera": "Cam2",
		"nome": "Charles",
		"texto": '"..."'
	},
	
	{
		"camera": "Cam4"
	},
	
	{
	"move": {
		"node": "Notificação",
		"target": "Markers/notify",
		"time": 0.2
	},
	},
	
	{
		"nome": "Charles",
		"texto": 'É nada'
	},
	
	{
		"camera": "Cam5"
	},
	
	{
		"nome": "Charles",
		"texto": 'HAHAHAHAHAHAH FAVELA VENCEU'
	},
	
	{
		"nome": "Charles",
		"texto": '"Saque presencial?" eu tenho que ir lá é agora!'
	},
	
]

# =========================================================
# STATE
# =========================================================

var indice := 0
var pode_avancar := false
var escrevendo := false

var camera_atual = null

var evento_rodando := false
var skip_evento := false

var texto_completo := ""
# =========================================================
# READY
# =========================================================

func _ready():

	registrar_cameras()

	fade.modulate.a = 1.0

	iniciar_cutscene()

# =========================================================
# CAMERA SYSTEM
# =========================================================

func registrar_cameras():

	for cam in $CameraPoints.get_children():

		cameras[cam.name] = cam

func mover_camera(nome_camera: String, instantaneo := false):

	if not cameras.has(nome_camera):
		push_warning("Camera não encontrada: " + nome_camera)
		return

	var alvo = cameras[nome_camera]

	camera_atual = nome_camera

	if instantaneo:
		camera_rig.global_transform = alvo.global_transform
		return

	evento_rodando = true
	skip_evento = false

	var tween = create_tween()

	tween.tween_property(
		camera_rig,
		"global_position",
		alvo.global_position,
		camera_move_duration
	)

	tween.parallel().tween_property(
		camera_rig,
		"global_rotation",
		alvo.global_rotation,
		camera_move_duration
	)

	while tween.is_running():

		if skip_evento:

			camera_rig.global_transform = alvo.global_transform

			tween.kill()

			break

		await get_tree().process_frame

	evento_rodando = false

# =========================================================
# CUTSCENE START
# =========================================================

func iniciar_cutscene():

	# força câmera inicial
	if dialogos[0].has("camera"):
		await mover_camera(dialogos[0]["camera"], true)

	var tween = create_tween()

	tween.tween_property(
		fade,
		"modulate:a",
		0.0,
		fade_in_duration
	)

	await tween.finished

	mostrar_dialogo()

# =========================================================
# DIALOG SYSTEM
# =========================================================

func mostrar_dialogo():

	pode_avancar = false

	var d = dialogos[indice]

	if d.has("camera"):

		if d["camera"] != camera_atual:

			await mover_camera(d["camera"])

	if d.has("move"):
		await executar_movimento(d["move"])

	# -----------------------------
	# DIALOGO
	# -----------------------------

	var tem_texto = d.has("texto")

	dialog_box.visible = tem_texto
	name_label.visible = tem_texto
	text_label.visible = tem_texto

	if tem_texto:

		name_label.text = d.get("nome", "")

		await escrever_texto(
			d.get("texto", "")
		)

	pode_avancar = true

# =========================================================
# TYPEWRITER
# =========================================================

func escrever_texto(texto: String):

	escrevendo = true

	texto_completo = texto

	text_label.text = ""

	for letra in texto:

		if not escrevendo:
			text_label.text = texto
			return

		text_label.text += letra

		await get_tree().create_timer(text_speed).timeout

	escrevendo = false

# =========================================================
# INPUT
# =========================================================

func _input(event):

	if event is InputEventMouseButton and event.pressed:

		# Se estiver digitando, completa o texto
		if escrevendo:

			escrevendo = false
			return

		# Futuro sistema de eventos
		if evento_rodando:

			skip_evento = true
			return

		if not pode_avancar:
			return

		avancar_dialogo()

# =========================================================
# NEXT DIALOG
# =========================================================

func executar_movimento(data):

	evento_rodando = true
	skip_evento = false

	var node = get_node(data["node"])
	var target = get_node(data["target"])

	var tween = create_tween()

	tween.tween_property(
		node,
		"global_position",
		target.global_position,
		data.get("time", 1.0)
	)

	while tween.is_running():

		if skip_evento:

			node.global_position = target.global_position

			tween.kill()

			break

		await get_tree().process_frame

	evento_rodando = false

func avancar_dialogo():

	indice += 1

	if indice >= dialogos.size():

		finalizar_cutscene()
		return

	mostrar_dialogo()

# =========================================================
# END
# =========================================================

func finalizar_cutscene():

	pode_avancar = false

	var tween = create_tween()

	tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		fade_out_duration
	)

	await tween.finished

	if proxima_cena != "":
		get_tree().change_scene_to_file(proxima_cena)
	else:
		queue_free()
