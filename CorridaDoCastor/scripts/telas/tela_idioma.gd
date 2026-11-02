extends Tela
## Escolha de idioma, mostrada só na primeira vez.


func _ready() -> void:
	visual_interface("fundo_menu", Vector2(0, 479))
	var es := _botao_imagem("botao_es", "botao_es_sobre", Vector2(40, 330), "es")
	var pt := _botao_imagem("botao_pt", "botao_pt_sobre", Vector2(340, 330), "pt")
	pt.grab_focus()
	es.focus_neighbor_right = pt.get_path()


func _botao_imagem(nome: String, sobre: String, pos: Vector2, cod: String) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = load("res://arte/intro/%s.png" % nome)
	b.texture_hover = load("res://arte/intro/%s.png" % sobre)
	b.texture_focused = load("res://arte/intro/%s.png" % sobre)
	b.position = pos
	b.pressed.connect(func():
		Jogo.idioma = cod
		Jogo.salvar_preferencias()
		concluida.emit("ok"))
	add_child(b)
	return b
