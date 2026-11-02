extends Personagem
## Carro que atravessa quando o jogador cruza com o semáforo vermelho.


func estado_idle() -> void:
	visivel = false
	if jogo.cor_semaforo == &"vermelho" and jogo.jogador.estado != &"morrendo" and tocou_jogador():
		visivel = true
		_trocar_estado(&"passando")


func estado_passando() -> void:
	if tocou_jogador():
		jogo.tocou_mortal()
	if visual and visual.fim_do_estado:
		visivel = false
		_trocar_estado(&"idle")
