extends Caminhante
## Cai quando o jogador chega perto.

var distancia_queda = 0
var _caindo := false


func preparar() -> void:
	gravidade = 0
	distancia_queda = parametro("distancia_queda", 0)


func definir_apoio(_obj) -> void:
	visivel = false
	estado = &"morta"


func estado_idle() -> void:
	if not _caindo and abs(jogo.jogador.pos_x - pos_x) < distancia_queda:
		_caindo = true
		gravidade = 3
	if tocou_jogador():
		jogo.tocou_hostil()
