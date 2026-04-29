extends CanvasLayer

# Ajustei o caminho para o nó Label que está dentro de GUI
@onready var label_status = $GUI/Label 

# AS VARIÁVEIS PRECISAM FICAR AQUI FORA (Topo do script)
var vida_texto = "100"
var aura_texto = "1000"

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vida_alterada.connect(_ao_mudar_vida)
		player.aura_alterada.connect(_ao_mudar_aura)
		
		# Opcional: Pegar o valor inicial direto do player
		vida_texto = str(player.vida)
		aura_texto = str(player.aura)
		_atualizar_display()

func _ao_mudar_vida(valor):
	vida_texto = str(valor)
	_atualizar_display()

func _ao_mudar_aura(valor):
	aura_texto = str(valor)
	_atualizar_display()

func _atualizar_display():
	label_status.text = "LIFE: " + vida_texto + "\nAURA: " + aura_texto
