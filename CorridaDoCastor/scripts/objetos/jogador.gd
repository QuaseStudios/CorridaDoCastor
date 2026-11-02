class_name Jogador
extends Caminhante
## O personagem principal. Valores de movimento em passos de 1/30 de segundo.

const FORCA_PULO := 40
const VELOCIDADE_MAXIMA := 15
const ACELERACAO := 2
const VELOCIDADE_NO_AR := 10
const TEMPO_IMUNE_MS := 3000
const VIDAS_INICIAIS := 2
const TEMPO_MORTE_MS := 2000
const VEZES_FESTEJO := 3
const TEMPO_FESTEJO_MS := 400
const FESTEJO_X := 10
const FESTEJO_Y := 20

var imune := false
var inicio_imune := 0.0
var itens_especiais := 0
var itens_comuns := 0
var vidas := VIDAS_INICIAIS
var placar := 0
var impulso_x = 0
var largura_visual = 200
var altura_visual = 120
var _inicio_morte := 0.0
var _contagem_festejo := 0
var _inicio_festejo := 0.0


func preparar() -> void:
	var info: Dictionary = jogo.info_visual(_caminho_visual)
	largura_visual = int(info.tamanho.x)
	altura_visual = int(info.tamanho.y)


func definir_apoio(obj) -> void:
	apoiado_sobre = obj
	if estado == &"saltando":
		definir_estado(&"correndo")


func tornar_imune() -> void:
	inicio_imune = jogo.ms
	imune = true


func atualizar() -> void:
	_rodar_estado()
	if jogo.jogador == null:
		return
	if imune:
		var passou: float = jogo.ms - inicio_imune
		if passou > TEMPO_IMUNE_MS:
			imune = false
			visivel = true
		else:
			visivel = fmod(passou, 300.0) > 150.0
	if apoiado_sobre != null:
		apoiado_sobre.acao_apoiado(self)
	else:
		veloc_y -= gravidade
	definir_posicao(pos_x + veloc_x, pos_y + veloc_y)
	if pos_y < jogo.limite_inferior:
		jogo.tocou_mortal()


func ativado() -> void:
	direcao = direcao_visual


func definir_estado(novo: StringName) -> void:
	if estado == novo:
		return
	match novo:
		&"saltando":
			Som.parar("correndo")
			Som.tocar_efeito("snd_saltando")
			apoiado_sobre = null
			veloc_y = FORCA_PULO
		&"correndo":
			Som.tocar_efeito("snd_corriendo", "correndo")
		&"festejando":
			Som.parar("correndo")
			veloc_x = FESTEJO_X
			veloc_y = FESTEJO_Y
			_contagem_festejo = VEZES_FESTEJO
			_inicio_festejo = jogo.ms
			apoiado_sobre = null
		&"parado", &"agachado":
			Som.pausar("correndo")
			veloc_x = 0
		&"morrendo":
			Som.parar("correndo")
			_inicio_morte = jogo.ms
			veloc_x = 0
	_trocar_estado(novo)


func definir_direcao(nova: StringName) -> void:
	if direcao != nova and visual:
		visual.espelhar(nova != &"right")
	direcao = nova


func estado_idle() -> void:
	jogo.comeca_vida()


func estado_morrendo() -> void:
	veloc_x = 0
	impulso_x = 0
	if jogo.ms - _inicio_morte > TEMPO_MORTE_MS:
		jogo.comeca_vida()


func estado_festejando() -> void:
	if _contagem_festejo > 0:
		if apoiado_sobre != null:
			apoiado_sobre = null
			veloc_x = FESTEJO_X
			veloc_y = FESTEJO_Y
		if jogo.ms - _inicio_festejo > TEMPO_FESTEJO_MS:
			_contagem_festejo -= 1
			_inicio_festejo = jogo.ms
	else:
		veloc_x = 0
		if visual:
			visual.parar()


func _ler_movimento() -> void:
	if jogo.esq:
		definir_direcao(&"left")
		definir_estado(&"correndo")
	if jogo.dir:
		definir_direcao(&"right")
		definir_estado(&"correndo")
	if jogo.cima and apoiado_sobre != null:
		definir_estado(&"saltando")
	if jogo.baixo:
		definir_estado(&"agachado")


func estado_parado() -> void:
	veloc_x = 0
	impulso_x = 0
	if jogo.alguma_tecla:
		_ler_movimento()


func estado_correndo() -> void:
	if direcao == &"right":
		impulso_x = min(impulso_x + ACELERACAO, VELOCIDADE_MAXIMA)
	else:
		impulso_x = max(impulso_x - ACELERACAO, -VELOCIDADE_MAXIMA)
	veloc_x = impulso_x
	if jogo.alguma_tecla:
		_ler_movimento()
	else:
		definir_estado(&"parado")


func estado_agachado() -> void:
	veloc_x = 0
	impulso_x = 0
	if not jogo.baixo:
		definir_estado(&"parado")


func estado_saltando() -> void:
	if abs(veloc_x) < VELOCIDADE_NO_AR and (jogo.esq or jogo.dir):
		veloc_x = VELOCIDADE_NO_AR if direcao == &"right" else -VELOCIDADE_NO_AR
	if jogo.alguma_tecla:
		if jogo.esq and direcao == &"right":
			definir_direcao(&"left")
			veloc_x = -veloc_x
			impulso_x = -impulso_x
		if jogo.dir and direcao == &"left":
			veloc_x = -veloc_x
			impulso_x = -impulso_x
			definir_direcao(&"right")
