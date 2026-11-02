class_name Chao
extends Personagem
## Superfície em que os caminhantes se apoiam.


func acao_apoiado(obj) -> void:
	obj.veloc_y = 0


func _apoiar(obj) -> void:
	obj.definir_apoio(self)
	obj.definir_posicao(null, colisao.topo() - 1)


func _desapoiar(obj) -> void:
	obj.apoiado_sobre = null


func verificar_caminhantes() -> void:
	for obj in jogo.caminhantes_ativos:
		if colide_com(obj):
			if obj.apoiado_sobre != self:
				if obj.pos_y_ant != null and obj.pos_y_ant >= colisao.topo() - 1:
					_apoiar(obj)
		elif obj.apoiado_sobre == self:
			_desapoiar(obj)


func estado_idle() -> void:
	verificar_caminhantes()
