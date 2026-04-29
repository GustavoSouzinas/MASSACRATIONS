extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_time := 2.0
@export var max_enemies := 5

var current_enemies := 0

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_time).timeout
		
		if current_enemies < max_enemies:
			spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# posição do spawner
	enemy.global_position = global_position
	
	get_parent().add_child(enemy)
	
	current_enemies += 1
	
	# quando o inimigo morrer, diminui contador
	enemy.tree_exited.connect(_on_enemy_removed)

func _on_enemy_removed():
	current_enemies -= 1
