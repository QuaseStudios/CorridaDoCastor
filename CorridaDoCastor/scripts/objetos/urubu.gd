extends Personagem

const DISTANCIA_ATAQUE := 400
const VELOCIDADE := 12


func preparar() -> void:
	direcao_visual = &"left"
	direcao = &"left"


func estado_idle() -> void:
	_trocar_estado(&"parado")


func estado_parado() -> void:
	if jogo.jogador.pos_x - pos_x > -DISTANCIA_ATAQUE:
		definir_posicao(null, pos_y + 20)
		_trocar_estado(&"voando")


func estado_voando() -> void:
	definir_posicao(pos_x - VELOCIDADE, null)
	if tocou_jogador():
		jogo.tocou_hostil()
