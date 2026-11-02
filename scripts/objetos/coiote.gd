extends InimigoCaminhante
## Inimigo que uiva de tempos em tempos enquanto espera.

const TEMPO_UIVO_MS := 4000

var _inicio := 0.0


func preparar() -> void:
	super()
	_inicio = jogo.ms


func estado_parado() -> void:
	veloc_x = 0
	if abs(distancia_jogador()) < distancia_visao:
		definir_estado(&"caminhando")
	elif jogo.ms - _inicio > TEMPO_UIVO_MS:
		_inicio = jogo.ms
		if visual:
			visual.animar("uivando")
		Som.tocar_efeito(cfg.get("som_uivo", ""))
