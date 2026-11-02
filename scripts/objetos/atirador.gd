extends Objeto
## Boneco de neve e macaco: atiram projéteis de tempos em tempos.

var intervalo = 2000
var veloc_disparo = -20
var _inicio := 0.0


func preparar() -> void:
	_inicio = jogo.ms
	intervalo = parametro("intervalo_disparo_ms", 2000)
	veloc_disparo = parametro("velocidade_disparo", -20)


func definir_na_tela(sim: bool) -> void:
	if na_tela != sim:
		if sim and som != "":
			Som.tocar_efeito(som)
		na_tela = sim


func estado_idle() -> void:
	if jogo.ms - _inicio > intervalo:
		_inicio = jogo.ms
		if visual:
			visual.animar("atacar")
		jogo.criar_projetil(pos_x, pos_y, cfg.projetil, cfg.colisao_projetil, {"velocidade": veloc_disparo})
