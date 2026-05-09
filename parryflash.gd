extends ColorRect

@export var flash_time := 0.08



func _ready():
	modulate.a = 0.0

func flash():
	# aparece
	modulate.a = 1.0
	
	# espera um pouco (ignora time_scale)
	await get_tree().create_timer(flash_time, false, true).timeout
	
	# some
	modulate.a = 0.0
