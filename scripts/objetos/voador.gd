extends Personagem
## Águia, mosquito, pomba, pardal: voam em linha reta.

var veloc_x = -10


func preparar() -> void:
	veloc_x = parametro("velocidade", -10)


func estado_idle() -> void:
	var anim: String = cfg.get("animacao", "")
	if anim != "":
		_trocar_estado(StringName(anim))
	else:
		_voar()


func estado_voando() -> void:
	_voar()


func _voar() -> void:
	definir_posicao(pos_x + veloc_x, null)
	if tocou_jogador():
		jogo.tocou_hostil()
