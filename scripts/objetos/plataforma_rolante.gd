extends Chao
## Empurra quem está em cima (troncos giratórios).

var forca = 0


func preparar() -> void:
	forca = parametro("forca", 0)


func acao_apoiado(obj) -> void:
	obj.veloc_x += forca
	obj.veloc_y = 0
