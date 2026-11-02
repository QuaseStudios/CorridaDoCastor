extends Personagem
## Borda de buraco: impede que o caminhante avance por cima dela.


func estado_idle() -> void:
	for obj in jogo.caminhantes_ativos:
		if colide_com(obj):
			obj.veloc_x = 0
			obj.definir_posicao(obj.pos_x_ant, null)
