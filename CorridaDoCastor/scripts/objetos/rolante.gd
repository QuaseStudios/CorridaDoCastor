extends Caminhante
## Arbusto, tronco, lixeira e roda: vêm rolando e quicando na direção do jogador.

var velocidade = -17
var quique = 10
var som_quique := ""
var som_choque := ""


func preparar() -> void:
	direcao_visual = &"left"
	direcao = &"left"
	gravidade = n(cfg.get("gravidade", 4))
	velocidade = parametro("velocidade", -17)
	quique = n(params.get("forca_quique", cfg.get("quique", 10)))
	som_quique = cfg.get("som_quique", "")
	som_choque = cfg.get("som_choque", "")


func desativado() -> void:
	if abs(pos_x - pos_x_inicial) > 840:
		jogo.excluir_depois(self)


func estado_idle() -> void:
	if som_choque != "":
		Som.tocar_efeito(som_choque)
		som_choque = ""
	if apoiado_sobre != null:
		veloc_y = quique
		apoiado_sobre = null
		if som_quique != "":
			Som.tocar_efeito(som_quique)
	veloc_x = velocidade
	if tocou_jogador():
		jogo.tocou_hostil()
