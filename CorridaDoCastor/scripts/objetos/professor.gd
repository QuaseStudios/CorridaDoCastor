extends Objeto


func estado_idle() -> void:
	if pos_x < jogo.jogador.pos_x:
		if visual:
			visual.espelhar(true)
			visual.continuar()
		estado = &"chegou"
