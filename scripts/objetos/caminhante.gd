class_name Caminhante
extends Personagem
## Personagem com gravidade, que anda sobre chãos e plataformas.

var apoiado_sobre = null
var veloc_x = 0
var veloc_y = 0
var gravidade = 4


func atualizar() -> void:
	_rodar_estado()
	if apoiado_sobre != null:
		apoiado_sobre.acao_apoiado(self)
	else:
		veloc_y -= gravidade
	definir_posicao(pos_x + veloc_x, pos_y + veloc_y)
	if pos_y < jogo.limite_inferior:
		jogo.excluir_depois(self)


func definir_apoio(obj) -> void:
	apoiado_sobre = obj
	definir_posicao(null, obj.colisao.topo() - 1)


func bateu_na_parede(_obj) -> void:
	pass
