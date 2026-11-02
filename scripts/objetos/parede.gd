class_name Parede
extends Personagem


func estado_idle() -> void:
	for obj in jogo.caminhantes_ativos:
		var w: float = colisao.largura_sobreposicao(obj.colisao)
		if w < 0.0:
			continue
		if obj == jogo.jogador and obj.estado == &"agachado":
			obj.definir_estado(&"parado")
			continue
		var meio = pos_x + esquerda + largura / 2
		if obj.pos_x < meio:
			obj.veloc_x = 0
			obj.definir_posicao(obj.pos_x - w)
		elif obj.pos_x > meio:
			obj.veloc_x = 0
			obj.definir_posicao(obj.pos_x + w)
		obj.bateu_na_parede(self)
