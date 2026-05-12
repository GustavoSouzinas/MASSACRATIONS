extends Node

var active = false
var timer: Timer
var audio: AudioStreamPlayer


func _ready():
	
	timer = Timer.new()
	timer.one_shot = true
	timer.ignore_time_scale = true
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	
	
	
	audio = AudioStreamPlayer.new()
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(audio)
	
	audio.stream = load("res://assets/audios/parry.mp3")

func freeze(duration := 0.05):
	if active:
		return
	
	active = true
	
	if audio.stream:
		audio.play()
	
	var flash = get_tree().get_first_node_in_group("flash")
	if flash:
		flash.flash()
	
	Engine.time_scale = 0.02
	
	timer.start(duration)

func _on_timeout():
	Engine.time_scale = 1.0
	active = false
