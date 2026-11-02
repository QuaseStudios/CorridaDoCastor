class_name Hud
extends CanvasLayer
## Placar: vidas, pontos, itens coletados e progresso na fase.
## As posições vêm do jogo original (tela de 640x480).

const X_ESPECIAIS := [23, 35, 47, 61, 73, 85, 98, 110, 122, 135]
const X_COMUNS := [22, 34, 47, 59, 72, 83]
const Y_ESPECIAIS := 434
const Y_COMUNS := 461
const PASTA := "res://arte/interface/"

var _vidas: Label
var _pontos: Label
var _especiais: Array[Visual] = []
var _comuns: Array[Visual] = []
var _direita: Node2D
var _painel_fase: Node2D
var _painel: Visual = null
var _marcador: Sprite2D
var _trajeto: Array = []
var _efeito_item: Visual
var _efeito_100: Visual
var _efeito_600: Visual


func _ready() -> void:
	layer = 5
	_painel_fase = Node2D.new()
	_direita = Node2D.new()
	add_child(_direita)
	_direita.add_child(_painel_fase)
	_marcador = Sprite2D.new()
	_direita.add_child(_marcador)
	_adicionar("hud_vidas", Vector2(46, 27))
	_direita.add_child(_criar("hud_pontos", Vector2(577, 23)))
	_adicionar("hud_cabeca", Vector2(31, 20))
	_vidas = _rotulo(Vector2(45, 17), Vector2(29, 21))
	add_child(_vidas)
	_pontos = _rotulo(Vector2(546, 15), Vector2(76, 15))
	_direita.add_child(_pontos)
	_adicionar("hud_itens", Vector2(79, 445))
	for x in X_ESPECIAIS:
		_especiais.append(_adicionar("hud_item_especial", Vector2(x, Y_ESPECIAIS)))
	for x in X_COMUNS:
		_comuns.append(_adicionar("hud_item_comum", Vector2(x, Y_COMUNS)))
	_efeito_item = _adicionar("hud_efeito_item", Vector2(23, 434))
	_efeito_item.visible = false
	_efeito_100 = _adicionar("efeito_100", Vector2(307, 170))
	_efeito_600 = _adicionar("efeito_600", Vector2(380, 168))
	limpar()
	get_viewport().size_changed.connect(_ajustar_largura)
	_ajustar_largura()


## Mantém os pontos e o painel da fase presos ao lado direito da tela.
func _ajustar_largura() -> void:
	_direita.position.x = get_viewport().get_visible_rect().size.x - 640.0


func _criar(nome: String, pos: Vector2) -> Visual:
	var v: Visual = load(PASTA + nome + "/visual.tscn").instantiate()
	v.position = pos
	return v


func _adicionar(nome: String, pos: Vector2) -> Visual:
	var v := _criar(nome, pos)
	add_child(v)
	return v


func _rotulo(pos: Vector2, tam: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = tam
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 3)
	return l


func limpar() -> void:
	_vidas.text = "0"
	_pontos.text = "0"
	for v in _especiais + _comuns:
		v.visible = false


func preparar_fase(fase: Dictionary) -> void:
	if _painel:
		_painel.queue_free()
	_painel = load(fase.visuais_fixos.painel).instantiate()
	_painel.position = Vector2(525, 424)
	_painel_fase.add_child(_painel)
	_marcador.texture = load(fase.marcador.imagem)
	_trajeto = fase.marcador.trajeto
	definir_progresso(0.0)


func atualizar(j: Jogador) -> void:
	_vidas.text = str(max(j.vidas, 0))
	_pontos.text = str(j.placar)
	for i in _especiais.size():
		_especiais[i].visible = j.itens_especiais >= i + 1
	for i in _comuns.size():
		_comuns[i].visible = j.itens_comuns >= i + 1


func definir_progresso(percentual: float) -> void:
	if _trajeto.is_empty():
		return
	var t: float = clamp(percentual, 0.0, 100.0) / 100.0 * (_trajeto.size() - 1)
	var i := int(t)
	var a: Array = _trajeto[i]
	var b: Array = _trajeto[min(i + 1, _trajeto.size() - 1)]
	var f := t - i
	_marcador.position = Vector2(lerp(a[0], b[0], f), lerp(a[1], b[1], f))


func efeito_item_especial(numero: int) -> void:
	if numero < 1 or numero > X_ESPECIAIS.size():
		return
	_efeito_item.position = Vector2(X_ESPECIAIS[numero - 1], Y_ESPECIAIS)
	_efeito_item.visible = true
	_efeito_item.animar("seg_3")


func efeito_pontos(valor: int, pos_tela: Vector2) -> void:
	var v := _efeito_100 if valor == 100 else _efeito_600
	v.position = pos_tela - Vector2(50, 50)
	v.reset_physics_interpolation()
	v.continuar()
