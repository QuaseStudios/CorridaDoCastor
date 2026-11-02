class_name Objeto
extends RefCounted
## Base de tudo que existe numa fase. A lógica usa o eixo Y para cima (como no
## jogo original); a conversão para a tela fica em CameraJogo.para_tela().

var jogo   # autoload Jogo
var estado: StringName = &"idle"
var pos_x = 0
var pos_y = 0
var pos_z: int = 0
var cena: PackedScene = null
var visual: Visual = null
var visivel := true
var paisagem := false
var ativo := false
var params: Dictionary = {}
var cfg: Dictionary = {}
var dados_colisao: Dictionary = {}
var esquerda = 0
var direita = 0
var largura = 0
var perspectiva := 1.0
var pontos = 0
var som := ""
var na_tela := false
var _caminho_visual := ""


static func n(v):
	if v is float and v == floor(v):
		return int(v)
	return v


func iniciar(dados: Dictionary, config: Dictionary, motor) -> void:
	jogo = motor
	cfg = config
	pos_x = n(dados.x)
	pos_y = n(dados.y)
	pos_z = int(dados.z)
	_caminho_visual = dados.get("visual", "")
	if _caminho_visual != "":
		cena = jogo.cena_visual(_caminho_visual)
	if dados.has("colisao"):
		dados_colisao = jogo.dados_fase.colisoes.get(dados.colisao, {})
	params = dados.get("params", {})
	paisagem = cfg.get("paisagem", false)
	pontos = n(cfg.get("pontos", 0))
	som = cfg.get("som", "")
	preparar()


## Cada tipo prepara aqui seus valores iniciais.
func preparar() -> void:
	pass


func parametro(nome: String, padrao):
	return n(params.get(nome, cfg.get(nome, padrao)))


func pre_calcular() -> void:
	var info: Dictionary = jogo.info_visual(_caminho_visual)
	esquerda = -info.registro.x
	direita = info.tamanho.x - info.registro.x
	_fim_pre_calculo()


func _fim_pre_calculo() -> void:
	largura = abs(direita - esquerda)
	perspectiva = CameraJogo.FATOR_PERSPECTIVA[pos_z]


func dentro_dos_limites(c: CameraJogo) -> bool:
	var x_tela = pos_x - c.pos_x * perspectiva
	return x_tela + direita >= -Jogo.LIMITE_ATIVACAO and x_tela + esquerda <= CameraJogo.LARGURA_TELA + Jogo.LIMITE_ATIVACAO


func limiar_entrada() -> float:
	return (pos_x + esquerda - CameraJogo.LARGURA_TELA - Jogo.LIMITE_ATIVACAO) / perspectiva


func definir_na_tela(_sim: bool) -> void:
	pass


func ativado() -> void:
	pass


func desativado() -> void:
	pass


func atualizar() -> void:
	_rodar_estado()


func _rodar_estado() -> void:
	var metodo := StringName("estado_" + estado)
	if has_method(metodo):
		call(metodo)
