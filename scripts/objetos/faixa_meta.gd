extends Personagem


func estado_idle() -> void:
	if tocou_jogador():
		_trocar_estado(&"romper")
