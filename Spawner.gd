extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_time := 2.0
@export var max_enemies := 5
@export var ativo := true

var current_enemies := 0
var running := false

func _ready():
	start_spawner()

func start_spawner():
	if running:
		return
	running = true
	spawn_loop()

func spawn_loop():
	while running:
		await get_tree().create_timer(spawn_time).timeout

		if not is_inside_tree():
			return

		if not ativo:
			continue

		if current_enemies < max_enemies:
			spawn_enemy()

func spawn_enemy():
	if enemy_scene == null:
		return

	var enemy = enemy_scene.instantiate()

	get_parent().add_child(enemy)
	enemy.global_position = global_position

	current_enemies += 1

	enemy.tree_exited.connect(func():
		current_enemies -= 1
	)

func stop_spawner():
	running = false
