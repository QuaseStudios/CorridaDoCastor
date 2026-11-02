class_name Tela
extends Control
## Base das telas de menu. As imagens vêm de arte/interface e arte/idioma_xx.

signal concluida(resultado: String)

var _regs := {}


func _init() -> void:
	size = Vector2(640, 480)
	# Faixa preta atrás da tela, enquanto as imagens dos menus forem 640x480.
	var faixa := ColorRect.new()
	faixa.color = Color.BLACK
	faixa.position = Vector2(-2000, 0)
	faixa.size = Vector2(4640, 480)
	faixa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(faixa)
	tree_entered.connect(_ao_entrar)


func _ao_entrar() -> void:
	get_viewport().size_changed.connect(_centralizar)
	_centralizar()


func _centralizar() -> void:
	position.x = (get_viewport().get_visible_rect().size.x - size.x) / 2.0


func idioma() -> String:
	return Jogo.idioma if Jogo.idioma != "" else "pt"


func texto(chave: String) -> String:
	var d = JSON.parse_string(FileAccess.get_file_as_string("res://dados/textos.json"))
	return d[idioma()].get(chave, chave)


## Coloca uma imagem de arte/<pasta>/<nome>.png com o ponto de registro em "pos".
func imagem_regs(pasta: String, nome: String, pos: Vector2) -> TextureRect:
	if not _regs.has(pasta):
		_regs[pasta] = JSON.parse_string(FileAccess.get_file_as_string("res://arte/%s/registros.json" % pasta))
	var r: Array = _regs[pasta][nome]
	var t := TextureRect.new()
	t.texture = load("res://arte/%s/%s.png" % [pasta, nome])
	t.position = pos - Vector2(r[2], r[3])
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(t)
	return t


func imagem_idioma(nome: String, pos: Vector2) -> TextureRect:
	return imagem_regs("idioma_" + idioma(), nome, pos)


func visual_interface(nome: String, pos: Vector2) -> Visual:
	var v: Visual = load("res://arte/interface/%s/visual.tscn" % nome).instantiate()
	v.position = pos
	add_child(v)
	return v


func botao(rotulo: String, rect: Rect2, acao: Callable) -> Button:
	var b := Button.new()
	b.text = rotulo
	b.position = rect.position
	b.custom_minimum_size = rect.size
	b.size = rect.size
	b.add_theme_font_size_override("font_size", 13)
	for nome in ["normal", "hover", "pressed", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color = Color("c9a572") if nome == "normal" else Color("e8c78f")
		if nome == "focus":
			s.draw_center = false
		s.set_corner_radius_all(6)
		s.set_border_width_all(1)
		s.border_color = Color("6b4f27")
		b.add_theme_stylebox_override(nome, s)
	for nome in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(nome, Color("1e1408"))
	b.pressed.connect(acao)
	add_child(b)
	return b
