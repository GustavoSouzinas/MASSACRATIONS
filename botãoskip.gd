extends Button


@onready var skip_button = $CanvasLayer/SkipButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skip_button.pressed.connect(skip_cutscene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func skip_cutscene():

	pode_avancar = false

	escrevendo = false
	skip_evento = true

	var tween = create_tween()

	tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		0.3
	)

	await tween.finished

	if proxima_cena != "":
		get_tree().change_scene_to_file(
			proxima_cena
		)
