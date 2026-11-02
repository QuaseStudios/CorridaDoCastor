extends Tela
## Pede o nome do jogador quando ele entra nos recordes.

var _nome: LineEdit


func _ready() -> void:
	visual_interface("fundo_vitoria" if Jogo.venceu else "fundo_derrota", Vector2(320, 240))
	imagem_idioma("pontuacao_final", Vector2(524, 20))
	imagem_idioma("grava_recorde", Vector2(311, 134))
	var p := Label.new()
	p.text = str(Jogo.pontos_finais)
	p.position = Vector2(368, 100)
	p.size = Vector2(120, 21)
	p.add_theme_color_override("font_color", Color.BLACK)
	add_child(p)
	_nome = LineEdit.new()
	_nome.position = Vector2(363, 145)
	_nome.size = Vector2(123, 24)
	_nome.max_length = 20
	_nome.text_submitted.connect(func(_t): _confirmar())
	add_child(_nome)
	_nome.grab_focus()
	botao(texto("aceitar"), Rect2(496, 143, 62, 28), _confirmar)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("menu"):
		concluida.emit("ok")


func _confirmar() -> void:
	Jogo.adicionar_recorde(_nome.text, Jogo.pontos_finais)
	concluida.emit("ok")
