extends Personagem
## Racha no gelo: abre quando o jogador pisa.


func ativado() -> void:
	estado = &"idle"
	colisao.definir(dados_colisao.get("idle"), Vector2(pos_x, pos_y))


func estado_idle() -> void:
	if tocou_jogador():
		_trocar_estado(&"rachando")
