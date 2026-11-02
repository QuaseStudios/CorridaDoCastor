extends Tela
## Abertura: Quase Studios apresenta, Quase Games com o foguete encaixando e depois o menu.
## Os tempos ficam em _rodar_linha_do_tempo(). Qualquer tecla ou clique pula a abertura.

const PASTA := "res://arte/marca/"
const ESCALA_LOGO := 0.42
const ANGULO_ENCAIXE := -141.7  # ângulo do foguete encaixado no logo
const TEMPO_VOO := 2.2
const POS_FOGUETE := Vector2(424, 286)  # lugar do foguete no logo, em pixels da imagem
const POS_FOGO := Vector2(132, 108)  # saída do fogo em relação ao centro do foguete
const DIRECAO_FOGO := Vector2(0.785, 0.62)
const ROXO_CLARO := Color(0.84, 0.76, 1.0)
const DURACAO_CAUDA := 0.45

var _estrelas: Control
var _studios: Control
var _studios_simbolo: TextureRect
var _studios_texto: Control
var _apresenta: Label
var _games: Control
var _games_logo: Control
var _games_simbolo: TextureRect
var _games_texto: Control
var _foguete: Node2D
var _rastro: CPUParticles2D
var _cauda: Line2D
var _idades: Array[float] = []
var _fogo_parado: CPUParticles2D
var _explosao: CPUParticles2D
var _flash: Sprite2D
var _dica: Label

var _curva := Curve2D.new()
var _tempo_voo := -1.0
var _pos_logo := Vector2.ZERO
var _larguras := {}
var _fim := false


## Estrelas piscando no fundo preto.
class Estrelas extends Control:
	const COR := Color("#d4ccff")
	var _lista: Array[Dictionary] = []
	var _tempo := 0.0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var rng := RandomNumberGenerator.new()
		rng.seed = 2026
		for i in 150:
			_lista.append({
				"pos": Vector2(rng.randf_range(-300.0, 940.0), rng.randf_range(0.0, 480.0)),
				"r": rng.randf_range(0.4, 1.0),
				"fase": rng.randf() * TAU,
			})

	func _process(delta: float) -> void:
		_tempo += delta
		queue_redraw()

	func _draw() -> void:
		for s in _lista:
			var a: float = 0.2 + 0.3 * sin(_tempo / 0.9 + s.fase)
			if a > 0.0:
				draw_circle(s.pos, s.r, Color(COR, a))


func _ready() -> void:
	# A animação roda fora dos passos do jogo, então não usa o movimento suavizado.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_estrelas = Estrelas.new()
	_estrelas.modulate.a = 0.0
	add_child(_estrelas)
	_montar_studios()
	_montar_games()
	_dica = _rotulo(texto("pular"), Rect2(0, 452, 640, 16), 9, Color(0.545, 0.525, 0.639))
	_dica.modulate.a = 0.0
	add_child(_dica)
	_criar_curva()
	_rodar_linha_do_tempo()


func _rodar_linha_do_tempo() -> void:
	var linha := create_tween().set_parallel(true)
	var em := func(tempo: float, acao: Callable) -> void:
		linha.tween_callback(acao).set_delay(tempo)
	_suavizar(_estrelas, 1.0, 0.8)
	em.call(1.0, func() -> void: _suavizar(_dica, 0.45, 1.0))
	em.call(0.4, func() -> void: _mostrar_grupo(_studios); _destacar_simbolo(_studios_simbolo))
	em.call(1.6, func() -> void: _revelar(_studios_texto))
	em.call(2.6, func() -> void: _suavizar(_apresenta, 1.0, 1.0))
	em.call(4.8, func() -> void: _esconder_grupo(_studios))
	em.call(5.7, func() -> void: _mostrar_grupo(_games); _destacar_simbolo(_games_simbolo))
	em.call(6.7, _lancar_foguete)
	em.call(9.0, func() -> void: _revelar(_games_texto))
	em.call(11.6, func() -> void: _esconder_grupo(_games); _suavizar(_estrelas, 0.0, 1.0); _suavizar(_dica, 0.0, 0.6))
	em.call(12.7, _terminar)


func _process(delta: float) -> void:
	if _tempo_voo >= 0.0:
		_tempo_voo += delta
		var p := minf(1.0, _tempo_voo / TEMPO_VOO)
		_atualizar_foguete(p)
		if _tempo_voo > 0.05 and p < 1.0:
			_rastro.emitting = true
		if p >= 1.0:
			_tempo_voo = -1.0
			_encaixar_foguete()
	_atualizar_cauda(delta)


func _input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton or evento is InputEventKey or evento is InputEventJoypadButton or evento is InputEventScreenTouch:
		if evento.is_pressed():
			get_viewport().set_input_as_handled()
			_terminar()


func _terminar() -> void:
	if not _fim:
		_fim = true
		Som.parar_tudo()
		concluida.emit("ok")


# ------------------------------------------------------------ montagem

func _grupo() -> Control:
	var g := Control.new()
	g.size = Vector2(640, 480)
	g.pivot_offset = g.size / 2.0
	g.modulate.a = 0.0
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(g)
	return g


## Logo em pixels da imagem original, reduzido para o tamanho da tela.
func _logo(pai: Control, tamanho: Vector2, y: float) -> Control:
	var l := Control.new()
	l.size = tamanho
	l.scale = Vector2(ESCALA_LOGO, ESCALA_LOGO)
	l.position = Vector2(320.0 - tamanho.x * ESCALA_LOGO / 2.0, y)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(l)
	return l


func _imagem(pai: Control, nome: String, pos: Vector2) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(PASTA + nome + ".png")
	t.position = pos
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(t)
	return t


## Texto que aparece da esquerda para a direita.
func _texto_revelado(pai: Control, nome: String, pos: Vector2) -> Control:
	var recorte := Control.new()
	recorte.clip_contents = true
	recorte.position = pos
	recorte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(recorte)
	var t := _imagem(recorte, nome, Vector2.ZERO)
	recorte.size = t.texture.get_size()
	_larguras[recorte] = recorte.size.x
	recorte.size.x = 0.0
	return recorte


func _rotulo(valor: String, area: Rect2, tamanho: int, cor: Color) -> Label:
	var fonte := FontVariation.new()
	fonte.base_font = ThemeDB.fallback_font
	fonte.spacing_glyph = 2
	var l := Label.new()
	l.text = valor
	l.position = area.position
	l.size = area.size
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", fonte)
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", cor)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _montar_studios() -> void:
	_studios = _grupo()
	var logo := _logo(_studios, Vector2(601, 577), 92.0)
	_studios_simbolo = _imagem(logo, "qs_simbolo", Vector2.ZERO)
	_studios_simbolo.modulate.a = 0.0
	_studios_texto = _texto_revelado(logo, "qs_texto", Vector2(0, 387))
	_apresenta = _rotulo("APRESENTA", Rect2(0, 346, 640, 20), 12, Color(0.545, 0.525, 0.639))
	_apresenta.modulate.a = 0.0
	_studios.add_child(_apresenta)


func _montar_games() -> void:
	_games = _grupo()
	_games_logo = _logo(_games, Vector2(602, 592), 116.0)
	_pos_logo = _games_logo.position
	_games_simbolo = _imagem(_games_logo, "qg_simbolo", Vector2.ZERO)
	_games_simbolo.modulate.a = 0.0
	_games_texto = _texto_revelado(_games_logo, "qg_texto", Vector2(0, 392))

	var ponto := _textura_ponto(32, Color.WHITE, Color.WHITE)
	var fogo := Gradient.new()
	fogo.offsets = PackedFloat32Array([0.0, 0.3, 0.6, 1.0])
	fogo.colors = PackedColorArray([Color(1, 0.96, 0.85, 1), Color(1, 0.7, 0.28, 0.9), Color(0.64, 0.36, 1, 0.6), Color(0.64, 0.36, 1, 0)])
	var faisca := Gradient.new()
	faisca.offsets = PackedFloat32Array([0.0, 1.0])
	faisca.colors = PackedColorArray([ROXO_CLARO, Color(ROXO_CLARO, 0.0)])

	# Cauda contínua do foguete: fica no logo, atrás dele.
	var cor_cauda := Gradient.new()
	cor_cauda.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	cor_cauda.colors = PackedColorArray([Color(0.64, 0.36, 1, 0), Color(0.75, 0.42, 0.9, 0.55), Color(1, 0.72, 0.35, 0.95)])
	var largura_cauda := Curve.new()
	largura_cauda.add_point(Vector2(0.0, 0.1))
	largura_cauda.add_point(Vector2(1.0, 1.0))
	_cauda = Line2D.new()
	_cauda.width = 16.0
	_cauda.width_curve = largura_cauda
	_cauda.gradient = cor_cauda
	_cauda.joint_mode = Line2D.LINE_JOINT_ROUND
	_cauda.material = _aditivo()
	_games_logo.add_child(_cauda)

	_foguete = Node2D.new()
	_foguete.position = POS_FOGUETE
	_foguete.visible = false
	_games_logo.add_child(_foguete)
	_rastro = _particulas(_foguete, ponto, fogo, 70, 0.5, POS_FOGO)
	_rastro.direction = DIRECAO_FOGO
	_rastro.spread = 20.0
	_rastro.local_coords = false
	_rastro.initial_velocity_min = 80.0
	_rastro.initial_velocity_max = 140.0
	_rastro.scale_amount_min = 0.1
	_rastro.scale_amount_max = 0.2
	_fogo_parado = _particulas(_foguete, ponto, fogo, 30, 0.5, POS_FOGO)
	_fogo_parado.direction = DIRECAO_FOGO
	_fogo_parado.spread = 25.0
	_fogo_parado.initial_velocity_min = 25.0
	_fogo_parado.initial_velocity_max = 55.0
	_fogo_parado.scale_amount_min = 0.08
	_fogo_parado.scale_amount_max = 0.14
	var corpo := Sprite2D.new()
	corpo.texture = load(PASTA + "qg_foguete.png")
	_foguete.add_child(corpo)

	_explosao = _particulas(_games_logo, ponto, faisca, 40, 0.8, POS_FOGUETE)
	_explosao.one_shot = true
	_explosao.explosiveness = 1.0
	_explosao.spread = 180.0
	_explosao.initial_velocity_min = 60.0
	_explosao.initial_velocity_max = 170.0
	_explosao.damping_min = 110.0
	_explosao.damping_max = 160.0
	_explosao.scale_amount_min = 0.12
	_explosao.scale_amount_max = 0.22

	_flash = Sprite2D.new()
	_flash.texture = _textura_ponto(64, Color(0.61, 0.36, 1, 0.6), Color(0.61, 0.36, 1, 0))
	_flash.position = POS_FOGUETE
	_flash.modulate.a = 0.0
	_flash.material = _aditivo()
	_games_logo.add_child(_flash)


func _textura_ponto(tamanho: int, meio: Color, fim: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	g.colors = PackedColorArray([Color.WHITE, meio, fim]) if meio != Color.WHITE else PackedColorArray([Color.WHITE, Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = tamanho
	t.height = tamanho
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	return t


func _aditivo() -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


func _particulas(pai: Node, textura: Texture2D, cores: Gradient, quantidade: int, vida: float, pos: Vector2) -> CPUParticles2D:
	var encolher := Curve.new()
	encolher.add_point(Vector2(0.0, 1.0))
	encolher.add_point(Vector2(1.0, 0.3))
	var p := CPUParticles2D.new()
	p.emitting = false
	p.amount = quantidade
	p.lifetime = vida
	p.texture = textura
	p.position = pos
	p.gravity = Vector2.ZERO
	p.scale_amount_curve = encolher
	p.color_ramp = cores
	p.material = _aditivo()
	pai.add_child(p)
	return p


# ------------------------------------------------------------ efeitos

func _mostrar_grupo(g: Control) -> void:
	g.scale = Vector2(0.97, 0.97)
	var t := create_tween().set_parallel(true)
	t.tween_property(g, "modulate:a", 1.0, 1.0)
	t.tween_property(g, "scale", Vector2.ONE, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _esconder_grupo(g: Control) -> void:
	var t := create_tween().set_parallel(true)
	t.tween_property(g, "modulate:a", 0.0, 1.0)
	t.tween_property(g, "scale", Vector2(1.04, 1.04), 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _suavizar(item: CanvasItem, para: float, tempo: float) -> void:
	create_tween().tween_property(item, "modulate:a", para, tempo)


func _destacar_simbolo(simbolo: TextureRect) -> void:
	simbolo.pivot_offset = simbolo.size / 2.0
	simbolo.scale = Vector2(0.6, 0.6)
	simbolo.self_modulate = Color(1.7, 1.4, 2.2)
	var t := create_tween().set_parallel(true)
	t.tween_property(simbolo, "modulate:a", 1.0, 0.8).set_delay(0.3)
	t.tween_property(simbolo, "scale", Vector2.ONE, 1.3).set_delay(0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(simbolo, "self_modulate", Color.WHITE, 0.9).set_delay(1.0)


func _revelar(recorte: Control) -> void:
	create_tween().tween_property(recorte, "size:x", _larguras[recorte], 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)


# ------------------------------------------------------------ foguete

## Trajetória em pixels do logo, relativa à posição final do foguete.
func _criar_curva() -> void:
	var a := Vector2(1280, 840)
	var b := Vector2(180, 520)
	var c := Vector2.ZERO
	_curva.add_point(a, Vector2.ZERO, Vector2(840, 1120) - a)
	_curva.add_point(b, Vector2(80, 920) - b, Vector2(280, 120) - b)
	_curva.add_point(c, Vector2(260, 190) - c, Vector2.ZERO)


func _lancar_foguete() -> void:
	_tempo_voo = 0.0
	_foguete.visible = true
	_atualizar_foguete(0.0)
	Som.tocar_efeito("foguete")


func _atualizar_foguete(p: float) -> void:
	var e := 1.0 - pow(1.0 - p, 3.0)
	var comprimento := _curva.get_baked_length()
	var d := e * comprimento
	var frente := _curva.sample_baked(minf(comprimento, d + 2.0))
	var tras := _curva.sample_baked(maxf(0.0, d - 2.0))
	var rumo := rad_to_deg((frente - tras).angle())
	_foguete.position = POS_FOGUETE + _curva.sample_baked(d)
	_foguete.rotation_degrees = rumo - ANGULO_ENCAIXE
	_foguete.scale = Vector2.ONE * (1.0 + (1.0 - e) * 0.25)


## A cauda segue a saída do fogo e some aos poucos.
func _atualizar_cauda(delta: float) -> void:
	for i in _idades.size():
		_idades[i] += delta
	while not _idades.is_empty() and _idades[0] > DURACAO_CAUDA:
		_idades.remove_at(0)
		_cauda.remove_point(0)
	if _tempo_voo >= 0.0:
		_cauda.add_point(_foguete.transform * POS_FOGO)
		_idades.append(0.0)


func _encaixar_foguete() -> void:
	_foguete.position = POS_FOGUETE
	_foguete.rotation = 0.0
	_foguete.scale = Vector2.ONE
	_rastro.emitting = false
	_fogo_parado.emitting = true
	_explosao.restart()
	Som.tocar_efeito("encaixe")

	_flash.scale = Vector2(0.7, 0.7)
	_flash.modulate.a = 1.0
	var luz := create_tween().set_parallel(true)
	luz.tween_property(_flash, "scale", Vector2(10, 10), 0.7).set_ease(Tween.EASE_OUT)
	luz.tween_property(_flash, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_OUT)

	var tranco := create_tween()
	tranco.tween_property(_games_logo, "position", _pos_logo + Vector2(3.2, 2.4), 0.1)
	tranco.tween_property(_games_logo, "position", _pos_logo + Vector2(-1.6, -1.2), 0.1)
	tranco.tween_property(_games_logo, "position", _pos_logo, 0.15)

	var flutuar := create_tween().set_loops()
	flutuar.tween_property(_foguete, "position", POS_FOGUETE + Vector2(-5, -5), 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	flutuar.tween_property(_foguete, "position", POS_FOGUETE, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
