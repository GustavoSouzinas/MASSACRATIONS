extends Label

@export var speed := 50.0
@onready var audio_player = $"../../../../map/OST"


var start_x : float

func _ready():
	update_song_name()
	start_x = position.x

func _process(delta):
	position.x += speed * delta

	if position.x > 120:
		position.x = start_x

func update_song_name():
	if audio_player.stream:
		text = audio_player.stream.resource_path.get_file().get_basename()
