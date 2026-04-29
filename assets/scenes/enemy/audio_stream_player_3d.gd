extends CharacterBody3D

@onready var audio = $AudioPlayer
@export var min_time := 2.0
@export var max_time := 5.0

func _ready():
	play_random_loop()

func play_random_loop():
	while true:
		var wait_time = randf_range(min_time, max_time)
		await get_tree().create_timer(wait_time).timeout
		
		audio.play()
