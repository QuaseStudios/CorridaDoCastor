class_name Tela
extends Control
## Base das telas de menu. As imagens vêm de arte/interface e arte/idioma_xx.

signal concluida(resultado: String)

const ARTE_MENU := "res://arte/menu/"
const ARTE_FONTE := "res://arte/fontes/Poppins-Bold.ttf"

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


## Fundo dos menus em 16:9. Em telas mais largas, as laterais são espelhadas e escurecidas.
func fundo_menu() -> void:
	var textura: Texture2D = load(ARTE_MENU + "fundo.png")
	for lado in [-1, 0, 1]:
		var t := TextureRect.new()
		t.texture = textura
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.size = Vector2(854, 480)
		t.position = Vector2(-107 + lado * 854, 0)
		t.flip_h = lado != 0
		if lado != 0:
			t.modulate = Color(0.3, 0.3, 0.3)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(t)


## Botão de madeira: "destaque" usa a tábua laranja. O ícone é opcional.
func tabua(rotulo: String, rect: Rect2, acao: Callable, destaque := false, icone := "") -> TextureButton:
	var b := TextureButton.new()
	var imagem := "tabua_laranja" if destaque else "tabua_marrom"
	b.texture_normal = load(ARTE_MENU + imagem + ".png")
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_SCALE
	b.position = rect.position
	b.size = rect.size
	b.custom_minimum_size = rect.size
	b.pivot_offset = rect.size / 2.0
	b.focus_mode = Control.FOCUS_ALL
	if icone != "":
		var i := TextureRect.new()
		i.texture = load(ARTE_MENU + "icone_" + icone + ".png")
		i.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		i.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		i.size = Vector2(rect.size.y, rect.size.y) * 0.5
		i.position = Vector2(rect.size.x * 0.13, rect.size.y * 0.25)
		i.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(i)
	var l := Label.new()
	l.text = rotulo
	l.size = rect.size
	l.position = Vector2(rect.size.y * 0.3 if icone != "" else 0.0, -1.0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", load(ARTE_FONTE))
	l.add_theme_font_size_override("font_size", int(rect.size.y * 0.36))
	l.add_theme_color_override("font_color", Color("fff3d6"))
	l.add_theme_color_override("font_outline_color", Color("3a1f0a"))
	l.add_theme_constant_override("outline_size", 4)
	b.add_child(l)
	b.mouse_entered.connect(_realcar.bind(b, true))
	b.mouse_exited.connect(func(): _realcar(b, b.has_focus()))
	b.focus_entered.connect(_realcar.bind(b, true))
	b.focus_exited.connect(_realcar.bind(b, false))
	b.pressed.connect(acao)
	add_child(b)
	return b


func _realcar(b: Control, sim: bool) -> void:
	var t := b.create_tween().set_parallel(true)
	t.tween_property(b, "scale", Vector2(1.04, 1.04) if sim else Vector2.ONE, 0.1)
	t.tween_property(b, "modulate", Color(1.18, 1.18, 1.18) if sim else Color.WHITE, 0.1)


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
