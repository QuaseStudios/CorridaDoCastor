extends Chao

var veloc = 2
var distancia = 200
var espera = 0
var veloc_x = 0
var _esperando := false
var _inicio := 0.0


func preparar() -> void:
	veloc = parametro("velocidade", 2)
	distancia = parametro("distancia", 200)
	espera = parametro("espera_ms", 0)
	veloc_x = -veloc


func acao_apoiado(obj) -> void:
	obj.veloc_y = 0
	var dx = 0 if pos_x_ant == null else pos_x - pos_x_ant
	obj.definir_posicao(obj.pos_x + dx, colisao.topo() - 1)


func estado_idle() -> void:
	verificar_caminhantes()
	if _esperando:
		if jogo.ms - _inicio > espera:
			_esperando = false
		return
	var d = pos_x - pos_x_inicial
	if veloc_x > 0:
		if d > distancia:
			_esperando = true
			_inicio = jogo.ms
			veloc_x = -veloc
	elif d < 0:
		_esperando = true
		_inicio = jogo.ms
		veloc_x = veloc
	definir_posicao(pos_x + veloc_x, null)
