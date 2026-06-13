extends TextureRect

@onready var aura = $"../aura"
@onready var audio = $AudioStreamPlayer

var aura_alta = false

func _ready():
	modulate.a = 0.0

func _process(_delta):

	if !aura:
		return

	var intensidade = clamp(
		aura.combo / 100.0,
		0.0,
		0.7
	)

	modulate.a = intensidade

	# entrou na aura alta
	if aura.combo > 60 and !aura_alta:

		aura_alta = true
		audio.play()

	# saiu da aura alta
	elif aura.combo <= 60:

		aura_alta = false
