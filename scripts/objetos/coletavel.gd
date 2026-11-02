extends Personagem
## Item que o jogador coleta (comum ou especial, definido no catálogo).

var _pego := false


func estado_idle() -> void:
	if not _pego and tocou_jogador():
		_pego = true
		visivel = false
		jogo.soma_item(cfg.get("especial", false))
