extends Area3D

@export var SPEED = 40.0
@export var DAMAGE = 5

var velocity = Vector3.ZERO
var parried = false
var bullet_owner = "enemy"

func _ready():
	add_to_group("enemy_bullets")


func _physics_process(delta):
	global_position += velocity * delta


func set_velocity(v):
	velocity = v


func _on_body_entered(body):
	if bullet_owner == "enemy" and body.is_in_group("player"):
		if body.has_method("tomar_dano"):
			body.tomar_dano(DAMAGE)
		queue_free()

	elif bullet_owner == "player" and body.is_in_group("enemies"):
		if body.has_method("die"):
			body.die()
		queue_free()


#parry
func parry(_player):
	if parried:
		return

	parried = true
	Hitstop.freeze(0.20)
	bullet_owner = "player"

	var enemies = get_tree().get_nodes_in_group("enemies")

	if enemies.size() == 0:
		return

	var alvo = null
	var min_dist = INF

	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < min_dist:
			min_dist = d
			alvo = e

	if alvo:
		var alvo_pos = alvo.global_position + Vector3.UP * 1.2

		var dir = (alvo_pos - global_position).normalized()

		velocity = dir * SPEED

	# feedback visual
	scale *= 1.8
