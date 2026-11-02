class_name InimigoCaminhante
extends Caminhante
## Inimigos que veem o jogador, andam até ele e atacam.

var distancia_visao = 350
var distancia_ataque = 40
var velocidade = 5


func preparar() -> void:
	direcao_visual = &"left"
	direcao = &"left"
	distancia_visao = parametro("distancia_visao", 350)
	distancia_ataque = parametro("distancia_ataque", 40)
	velocidade = parametro("velocidade", 5)


func definir_estado(novo: StringName) -> void:
	if estado != novo:
		_trocar_estado(novo)


func definir_direcao(nova: StringName) -> void:
	if direcao != nova and visual:
		visual.espelhar(nova != direcao_visual)
	direcao = nova


func distancia_jogador():
	return jogo.jogador.pos_x - pos_x


func estado_idle() -> void:
	definir_estado(&"parado")


func estado_parado() -> void:
	veloc_x = 0
	if abs(distancia_jogador()) < distancia_visao:
		definir_estado(&"caminhando")


func estado_caminhando() -> void:
	var dx = distancia_jogador()
	if abs(dx) > distancia_visao:
		definir_estado(&"parado")
	elif abs(dx) < distancia_ataque:
		definir_estado(&"atacando")
	elif dx > 0:
		if direcao != &"right":
			definir_direcao(&"right")
		veloc_x = velocidade
	else:
		if direcao != &"left":
			definir_direcao(&"left")
		veloc_x = -velocidade
	if tocou_jogador():
		jogo.tocou_hostil()


func estado_atacando() -> void:
	veloc_x = 0
	if visual and visual.fim_do_estado:
		definir_estado(&"caminhando")
	if tocou_jogador():
		jogo.tocou_hostil()
