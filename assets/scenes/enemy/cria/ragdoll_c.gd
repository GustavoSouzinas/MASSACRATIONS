extends Node3D

@onready var simulator = $Skeleton3D/PhysicalBoneSimulator3D

func _ready():
	pass

func iniciar(pos: Vector3, rot: Vector3, direcao_knockback: Vector3):
	global_position = pos
	global_rotation = rot
	simulator.physical_bones_start_simulation()
	
	await get_tree().process_frame
	lancar(direcao_knockback)
	
	await get_tree().create_timer(5.0).timeout
	queue_free()

func lancar(direcao: Vector3):
	var impulso_base = direcao.normalized() * 8.0 + Vector3(0, 6, 0)
	for bone in simulator.get_children():
		if bone is PhysicalBone3D:
			bone.collision_layer = 0b00001000
			bone.collision_mask  = 0b00000001
			
			var impulso = impulso_base + Vector3(
				randf_range(-2.0, 2.0),
				randf_range(0.0, 3.0),
				randf_range(-2.0, 2.0)
			)
			
			# Offset aleatório faz o impulso criar rotação natural
			var offset = Vector3(
				randf_range(-0.2, 0.2),
				randf_range(-0.2, 0.2),
				randf_range(-0.2, 0.2)
			)
			bone.apply_impulse(impulso, offset)
