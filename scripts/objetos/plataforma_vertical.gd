extends Chao

var veloc = 2
var distancia = 200
var espera = 0
var veloc_y = 0
var _esperando := false
var _inicio := 0.0


func preparar() -> void:
	veloc = parametro("velocidade_vertical", 2)
	distancia = parametro("distancia_subida", 200)
	espera = parametro("espera_ms", 0)
	veloc_y = -veloc


func acao_apoiado(obj) -> void:
	obj.veloc_y = 0
	obj.definir_posicao(null, colisao.topo() - 1)


func estado_idle() -> void:
	verificar_caminhantes()
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
