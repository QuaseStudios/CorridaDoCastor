extends Tela
## Abertura simplificada: troque as imagens e os sons da lista CENAS.

const CENAS := [
	{"imagem": "abertura_1", "som": "armado", "tempo": 1.4},
	{"imagem": "abertura_2", "som": "swat", "tempo": 1.2},
	{"imagem": "abertura_3", "som": "chu", "tempo": 1.6},
]

var _cor: ColorRect
var _imagem: TextureRect
var _indice := -1
var _resta := 0.0
var _fim := false


func _ready() -> void:
	_cor = ColorRect.new()
	_cor.color = Color.BLACK
	_cor.size = Vector2(640, 480)
	add_child(_cor)
	_imagem = TextureRect.new()
	_imagem.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	_imagem.size = Vector2(640, 480)
	add_child(_imagem)
	_proxima()


func _process(delta: float) -> void:
	_resta -= delta
	if _resta <= 0.0:
		_proxima()


func _input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton or evento is InputEventKey:
		if evento.is_pressed():
			get_viewport().set_input_as_handled()
			_terminar()


func _proxima() -> void:
	_indice += 1
	if _indice >= CENAS.size():
		_terminar()
		return
	var c: Dictionary = CENAS[_indice]
	_imagem.texture = load("res://arte/intro/%s.png" % c.imagem)
	Som.tocar_efeito(c.som)
	_resta = c.tempo


func _terminar() -> void:
	if not _fim:
		_fim = true
		Som.parar_tudo()
		concluida.emit("ok")
