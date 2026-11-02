extends Chao
## Gelo: acelera quem está em cima, na direção em que está virado.


func acao_apoiado(obj) -> void:
	if obj.direcao == &"right":
		obj.veloc_x = obj.veloc_x * 2 + 3
	else:
		obj.veloc_x = obj.veloc_x * 2 - 3
	obj.veloc_y = 0
