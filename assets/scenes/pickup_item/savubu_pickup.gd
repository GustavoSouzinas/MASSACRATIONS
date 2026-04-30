extends Area3D

@export var arma = 0
@export var quantidade = 5 #munição baixa pq ele vai explodir
@export var respawn_time = 7.0

@onready var sprite = $Sprite3D
@onready var colisao = $CollisionShape3D

var ativo = true

func _on_body_entered(body):
	if not ativo:
		return
		
	if body.is_in_group("player"):
		if body.aparato_atual != arma:
			return
		
		body.adicionar_municao(arma, quantidade)
		desativar_temporariamente()

func desativar_temporariamente():
	ativo = false
	
	# esconde
	sprite.visible = false
	colisao.disabled = true
	
	# espera e volta
	await get_tree().create_timer(respawn_time).timeout
	
	reativar()

func reativar():
	ativo = true
	sprite.visible = true
	colisao.disabled = false
