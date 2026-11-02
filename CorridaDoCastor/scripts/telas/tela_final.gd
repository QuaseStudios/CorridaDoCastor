extends Tela
## Cartão de vitória ou derrota no fim da partida.

const DURACAO := 4.0

var venceu := false
var _resta := DURACAO


func _ready() -> void:
	visual_interface("fundo_vitoria" if venceu else "fundo_derrota", Vector2(320, 240))
	if venceu:
		imagem_idioma("vitoria", Vector2(372, 126))
	else:
		imagem_idioma("derrota", Vector2(337, 210))


func _process(delta: float) -> void:
	_resta -= delta
	if _resta <= 0.0:
		set_process(false)
		concluida.emit("ok")
