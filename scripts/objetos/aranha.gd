extends Personagem

var veloc = 10
var distancia = 150
var espera = 500
var veloc_y = 0
var _esperando := false
var _inicio := 0.0


func preparar() -> void:
	veloc = parametro("velocidade_vertical", 10)
	distancia = parametro("distancia_descida", 150)
	espera = parametro("espera_ms", 500)
	veloc_y = -veloc


func estado_idle() -> void:
	if _esperando:
		if jogo.ms - _inicio > espera:
			_esperando = false
			if som != "":
				Som.tocar_efeito(som)
	else:
		var d = pos_y - pos_y_inicial
		if veloc_y > 0:
			if d > 0:
				_esperando = true
				_inicio = jogo.ms
				veloc_y = -veloc
		elif d < -distancia:
			_esperando = true
			_inicio = jogo.ms
			veloc_y = veloc
		definir_posicao(null, pos_y + veloc_y)
	if tocou_jogador():
		jogo.tocou_hostil()
