class_name CameraJogo
extends RefCounted
## Câmera do jogo: mesma lógica de acompanhamento da versão original.

const FATOR_PERSPECTIVA := {-5: 0.07, -4: 0.1, -3: 0.5, -2: 0.8, -1: 1.0, 0: 1.0, 1: 1.0, 2: 1.0}
const LARGURA_TELA := 640
const ALTURA_TELA := 480
const VELOCIDADE_X := 30
const ACELERACAO_Y := 12
const VELOCIDADE_MAX_Y := 50
const MARGEM_Y := 200

## Largura real da tela, que muda conforme o formato do monitor ou celular.
static var largura_real: float = 854.0

var pos_x = 0
var pos_y = 0
var alvo_y = 0
var veloc_y = 0
var limite_inferior = 0


func para_tela(x, y, z) -> Vector2:
	return Vector2(x - pos_x * FATOR_PERSPECTIVA[z], ALTURA_TELA - (y - pos_y))


func atualizar(j: Jogador) -> void:
	var alvo_x
	if j.direcao == &"right":
		alvo_x = j.pos_x - 150
	else:
		alvo_x = j.pos_x - (650 - j.largura_visual)
	if abs(pos_x - alvo_x) < VELOCIDADE_X:
		pos_x = alvo_x
	if pos_x - alvo_x > 300 and j.direcao == &"right":
		pos_x = j.pos_x + 100
		pos_y = 0
	if pos_x < alvo_x:
		pos_x += VELOCIDADE_X
	elif pos_x > alvo_x:
		pos_x -= VELOCIDADE_X

	var centro = j.pos_y + j.altura_visual / 2
	var delta = centro - pos_y
	if j.apoiado_sobre != null:
		if j.estado == &"agachado":
			alvo_y -= 8
		else:
			alvo_y = centro - ALTURA_TELA / 2
	else:
		if delta > ALTURA_TELA / 2 + MARGEM_Y or delta < ALTURA_TELA / 2 - MARGEM_Y:
			alvo_y = centro - ALTURA_TELA / 2
		if alvo_y < limite_inferior:
			alvo_y = limite_inferior

	if pos_y < alvo_y:
		veloc_y += ACELERACAO_Y
		pos_y += veloc_y
		if pos_y >= alvo_y:
			pos_y = alvo_y
			veloc_y = 0
		if veloc_y > VELOCIDADE_MAX_Y:
			veloc_y = VELOCIDADE_MAX_Y
	elif pos_y > alvo_y:
		veloc_y -= ACELERACAO_Y
		pos_y += veloc_y
		if pos_y <= alvo_y:
			pos_y = alvo_y
			veloc_y = 0
		if veloc_y < -VELOCIDADE_MAX_Y:
			veloc_y = -VELOCIDADE_MAX_Y
	if pos_y < limite_inferior:
		pos_y = limite_inferior
