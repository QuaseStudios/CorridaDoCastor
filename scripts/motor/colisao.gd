class_name Colisao
extends RefCounted
## Caixas de colisão. Cada caixa é [esquerda, topo, direita, base], relativa à
## posição do objeto, com o eixo Y apontando para cima (como no jogo original).

var areas: Array = []
var cache: Array = []


func definir(lista, ponto: Vector2, espelhado: bool = false) -> void:
	areas = lista if lista != null else []
	cache = []
	for a in areas:
		cache.append(a.duplicate())
	atualizar(ponto, espelhado)


func atualizar(ponto: Vector2, espelhado: bool = false) -> void:
	for i in areas.size():
		var a: Array = areas[i]
		var c: Array = cache[i]
		if espelhado:
			c[0] = -a[2] + ponto.x
			c[2] = -a[0] + ponto.x
		else:
			c[0] = a[0] + ponto.x
			c[2] = a[2] + ponto.x
		c[1] = a[1] + ponto.y
		c[3] = a[3] + ponto.y


## Devolve a largura da primeira sobreposição, ou -1 se não houver.
func largura_sobreposicao(outra: Colisao) -> float:
	for r1 in cache:
		for r2 in outra.cache:
			var e: float = max(r1[0], r2[0])
			var d: float = min(r1[2], r2[2])
			var b: float = max(r1[3], r2[3])
			var t: float = min(r1[1], r2[1])
			if d > e and t > b:
				return d - e
	return -1.0


func colide(outra: Colisao) -> bool:
	return largura_sobreposicao(outra) >= 0.0


func topo() -> float:
	return cache[0][1]
