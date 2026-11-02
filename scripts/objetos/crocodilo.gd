extends Personagem

var veloc = 4
var distancia = 100
var espera = 2000
var veloc_y = 0
var _esperando := false
var _inicio := 0.0


func preparar() -> void:
	veloc = parametro("velocidade_vertical", 4)
	distancia = parametro("distancia_subida", 100)
	espera = parametro("espera_ms", 2000)
	veloc_y = -veloc


func estado_idle() -> void:
	if tocou_jogador():
		jogo.tocou_hostil()
	if _esperando:
		if jogo.ms - _inicio > espera:
			_esperando = false
		return
	var d = pos_y - pos_y_inicial
	if veloc_y > 0:
		if d > distancia:
			_esperando = true
			_inicio = jogo.ms
			veloc_y = -veloc
	elif d < 0:
		_esperando = true
		_inicio = jogo.ms
		veloc_y = veloc
	definir_posicao(null, pos_y + veloc_y)
