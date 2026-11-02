extends Tela


func _ready() -> void:
	visual_interface("fundo_vitoria" if Jogo.venceu else "fundo_derrota", Vector2(320, 240))
	visual_interface("quadro_recordes", Vector2(320, 256))
	imagem_idioma("resultados", Vector2(549, 19))
	var nomes := ""
	var pontos := ""
	for i in Jogo.recordes.size():
		nomes += "%2d. %s\n" % [i + 1, Jogo.recordes[i].nome]
		pontos += "%d\n" % Jogo.recordes[i].pontos
	_coluna(nomes, Vector2(154, 127), Vector2(193, 281), HORIZONTAL_ALIGNMENT_LEFT)
	_coluna(pontos, Vector2(342, 127), Vector2(139, 281), HORIZONTAL_ALIGNMENT_RIGHT)


func _coluna(t: String, pos: Vector2, tam: Vector2, al: int) -> void:
	var l := Label.new()
	l.text = t
	l.position = pos
	l.size = tam
	l.horizontal_alignment = al
	l.add_theme_color_override("font_color", Color.BLACK)
	l.add_theme_font_size_override("font_size", 16)
	add_child(l)


func _input(evento: InputEvent) -> void:
	if (evento is InputEventMouseButton or evento.is_action("menu")) and evento.is_pressed():
		get_viewport().set_input_as_handled()
		concluida.emit("ok")
