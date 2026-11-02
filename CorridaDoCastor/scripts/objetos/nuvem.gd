extends Objeto

var veloc_x = -0.5


func preparar() -> void:
	veloc_x = parametro("velocidade", -0.5)


func estado_idle() -> void:
	pos_x += veloc_x
