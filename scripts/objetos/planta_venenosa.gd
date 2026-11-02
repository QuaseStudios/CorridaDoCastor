extends Personagem

var intervalo = 3000
var _inicio := 0.0


func preparar() -> void:
	_inicio = jogo.ms
	intervalo = parametro("intervalo_ataque_ms", 3000)


func estado_idle() -> void:
	if jogo.ms - _inicio > intervalo:
		_inicio = jogo.ms
		_trocar_estado(&"atacar")
	if tocou_jogador():
		jogo.tocou_hostil()


func estado_atacar() -> void:
	if visual and visual.fim_do_estado:
		_trocar_estado(&"idle")
	if tocou_jogador():
		jogo.tocou_hostil()
