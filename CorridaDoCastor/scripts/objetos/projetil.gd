extends Personagem

var veloc_x = -20


func preparar() -> void:
	veloc_x = parametro("velocidade", -20)


func ativado() -> void:
	super()
	if abs(pos_x - pos_x_inicial) > 640:
		jogo.excluir_depois(self)


func desativado() -> void:
	jogo.excluir_depois(self)


func estado_idle() -> void:
	definir_posicao(pos_x + veloc_x, null)
	if tocou_jogador():
		jogo.tocou_hostil()
