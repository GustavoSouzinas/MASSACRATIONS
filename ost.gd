extends AudioStreamPlayer

var player = null

var min_db = -7.0
var max_db = 10.0


@onready var song_name = $"../../gui/mp3_icon/TextArea/SongName"
@onready var mp3_icon = $"../../gui/mp3_icon"

func _ready():
	if stream:
		song_name.text = stream.resource_path.get_file().get_basename()
	
	if playing:
		_show_music_panel()

func _process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var t = player.get_cortisol_normalizado()
	var target_db = lerp(min_db, max_db, t)

	volume_db = lerp(volume_db, target_db, delta * 3.0)

func change_music(music: AudioStream):
	if stream == music:
		return

	stream = music
	
	song_name.text = stream.resource_path.get_file().get_basename()
	
	play()

	_show_music_panel()

func _show_music_panel():
	mp3_icon.show_mp3()

	#await get_tree().create_timer(15.0).timeout

	#mp3_icon.hide_mp3()
