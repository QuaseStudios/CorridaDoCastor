class_name Personagem
extends Objeto
## Objeto com caixas de colisão.

var direcao_visual: StringName = &"right"
var direcao: StringName = &"right"
var pos_x_ant = null
var pos_y_ant = null
var pos_x_inicial = 0
var pos_y_inicial = 0
var colisao := Colisao.new()


func iniciar(dados: Dictionary, config: Dictionary, motor) -> void:
	super(dados, config, motor)
	colisao.definir(dados_colisao.get(String(estado)), Vector2(pos_x, pos_y))
	pos_x_inicial = pos_x
	pos_y_inicial = pos_y


func pre_calcular() -> void:
	if _caminho_visual == "":
		esquerda = colisao.areas[0][0]
		direita = colisao.areas[0][2]
		_fim_pre_calculo()
	else:
		super()


func definir_na_tela(sim: bool) -> void:
	if na_tela != sim:
		if sim and som != "":
			Som.tocar_efeito(som)
		na_tela = sim


func colide_com(outro: Personagem) -> bool:
	return colisao.colide(outro.colisao)


func ativado() -> void:
	direcao = direcao_visual
	estado = &"idle"


func definir_posicao(x = null, y = null) -> void:
	if x != null:
		pos_x_ant = pos_x
		pos_x = x
	if y != null:
		pos_y_ant = pos_y
		pos_y = y
	colisao.atualizar(Vector2(pos_x, pos_y), direcao != direcao_visual)


## Troca a animação e as caixas de colisão para o novo estado.
func _trocar_estado(novo: StringName, animacao: String = "") -> void:
	if visual:
		visual.animar(animacao if animacao != "" else String(novo))
	estado = novo
	colisao.definir(dados_colisao.get(String(novo)), Vector2(pos_x, pos_y))


func tocou_jogador() -> bool:
	return colide_com(jogo.jogador)
