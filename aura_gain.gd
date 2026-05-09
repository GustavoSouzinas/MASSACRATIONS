extends Label

func criar_popup(texto, cor):

	var popup = Label.new()

	popup.text = texto
	popup.modulate = cor

	# tamanho da fonte
	popup.add_theme_font_size_override(
		"font_size",
		150
	)

	get_parent().add_child(popup)

	popup.global_position = global_position

	var direcao = -60

	if texto.begins_with("-"):
		direcao = 60

	var tween = create_tween()

	tween.parallel().tween_property(
		popup,
		"position:y",
		popup.position.y + direcao,
		0.6
	)

	tween.parallel().tween_property(
		popup,
		"modulate:a",
		0.0,
		0.6
	)

	tween.finished.connect(
		func():
			popup.queue_free()
	)
