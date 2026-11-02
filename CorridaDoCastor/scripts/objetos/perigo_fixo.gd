extends Personagem
## Cacto, serpente e outros perigos parados.


func estado_idle() -> void:
	if tocou_jogador():
		jogo.tocou_hostil()
