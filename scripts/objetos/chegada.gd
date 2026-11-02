class_name Chegada
extends Personagem


func estado_idle() -> void:
	if jogo.jogador.estado != &"festejando" and tocou_jogador():
		jogo.termino_de_fase()
