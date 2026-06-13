extends Control

@export var music_bus := "Music"

@export_group("Bars")
@export var bars := 16
@export var bar_spacing := 2.0
@export var min_height := 2.0
@export var multiplier := 1000.0
@export var bar_color := Color.WHITE

@export_group("Frequency Range")
@export var min_frequency := 20.0
@export var max_frequency := 20000.0

@export_group("Direction")
@export var invert_y := false



var spectrum

func _ready():
	spectrum = AudioServer.get_bus_effect_instance(
		AudioServer.get_bus_index(music_bus),
		0
	)

func _process(_delta):
	queue_redraw()

func _draw():
	if spectrum == null:
		return

	var bar_width = size.x / bars

	for i in bars:
		var t1 = float(i) / bars
		var t2 = float(i + 1) / bars

		var hz_min = min_frequency * pow(max_frequency / min_frequency, t1)
		var hz_max = min_frequency * pow(max_frequency / min_frequency, t2)

		var magnitude = spectrum.get_magnitude_for_frequency_range(
			hz_min,
			hz_max
		)

		var energy = magnitude.length()

		var height = clamp(
			energy * multiplier,
			min_height,
			size.y
		)

		var rect := Rect2()

		if invert_y:
			rect = Rect2(
				i * bar_width,
				0,
				bar_width - bar_spacing,
				height
			)
		else:
			rect = Rect2(
				i * bar_width,
				size.y - height,
				bar_width - bar_spacing,
				height
			)

		draw_rect(rect, bar_color)
