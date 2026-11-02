extends Personagem
## Segura o jogador enquanto ele atravessa.

var veloc_x = -1


func preparar() -> void:
	veloc_x = parametro("velocidade", -1)


func estado_idle() -> void:
	if tocou_jogador():
		jogo.jogador.impulso_x = int(jogo.jogador.impulso_x / 2)
		jogo.jogador.veloc_y = int(jogo.jogador.veloc_y / 2)
	definir_posicao(pos_x + veloc_x)
