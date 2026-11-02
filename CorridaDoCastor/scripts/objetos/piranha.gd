extends Personagem

var forca = 30
var grav = 3
var espera = 1500
var veloc_y = 0
var _esperando := false
var _inicio := 0.0


func preparar() -> void:
	forca = parametro("forca_salto", 30)
	grav = parametro("gravidade", 3)
	espera = parametro("espera_ms", 1500)


func estado_idle() -> void:
	if not _esperando:
		if tocou_jogador():
			jogo.tocou_hostil()
		veloc_y -= grav
		if visual:
			visual.espelhar(false, veloc_y < 0)
		definir_posicao(null, pos_y + veloc_y)
		if pos_y < pos_y_inicial:
			if som != "":
				Som.tocar_efeito(som)
			_inicio = jogo.ms
			_esperando = true
	elif jogo.ms - _inicio > espera:
		pos_y = pos_y_inicial
		_esperando = false
		veloc_y = forca
