extends Personagem

const DISTANCIA_ATAQUE := 350
const VELOCIDADE := 12


func preparar() -> void:
	direcao_visual = &"left"
	direcao = &"left"


func estado_idle() -> void:
	if jogo.jogador.pos_x - pos_x > -DISTANCIA_ATAQUE:
		definir_posicao(pos_x - VELOCIDADE, null)
		if tocou_jogador():
			jogo.tocou_hostil()
