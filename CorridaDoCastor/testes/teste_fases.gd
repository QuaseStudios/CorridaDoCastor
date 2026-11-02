extends Node
## Teste automático: um "robô" joga cada fase, procura erros e confere se o fim é alcançável.
## Rode pelo terminal:  godot --headless res://testes/teste_fases.tscn

const PASSOS_POR_FASE := 200000
const PASSOS_SEM_AVANCO := 12000

var _alcance := 110
var _frente := 60

func _ready() -> void:
	seed(12345)
	var principal = load("res://cenas/principal.tscn").instantiate()
	add_child(principal)
	await get_tree().process_frame
	var falhas := 0
	for nome in Jogo.FASES:
		falhas += _testar(nome)
	print("RESULTADO: %s" % ("OK" if falhas == 0 else "%d fase(s) com problema" % falhas))
	get_tree().quit(1 if falhas else 0)


func _testar(nome: String) -> int:
	Jogo.jogando = true
	Jogo.carregar_fase(nome)
	Jogo.estado = Jogo.Estado.JOGANDO
	var ativados := {}
	var maior_x := 0.0
	var ultimo_avanco := 0
	var saltos: Array = []
	var mortes := {}
	var i := 0
	var pulo := 0
	var concluiu := false
	var estado_ant := &""
	while i < PASSOS_POR_FASE:
		i += 1
		var j: Jogador = Jogo.jogador
		if j == null:
			break
		j.vidas = 2
		if j.pos_x > maior_x + 5:
			maior_x = j.pos_x
			ultimo_avanco = i
		if j.estado == &"morrendo" and estado_ant != &"morrendo":
			var chave := int(j.pos_x / 100) * 100
			mortes[chave] = mortes.get(chave, 0) + 1
		estado_ant = j.estado
		pulo = max(pulo - 1, 0)
		if i % 200 == 0:
			_alcance = randi_range(60, 170)
			_frente = randi_range(20, 100)
		if _deve_pular(j, i):
			pulo = 10
		Jogo.entrada_forcada = {"dir": true, "cima": pulo > 0}
		if i - ultimo_avanco > PASSOS_SEM_AVANCO and j.estado != &"morrendo":
			saltos.append(int(j.pos_x))
			_avancar_checkpoint(j, maior_x)
			ultimo_avanco = i
		Jogo.passo()
		if Jogo.jogador == null:
			break
		for o in Jogo.ativos:
			ativados[o] = true
		for o in Jogo.ativos_paisagem:
			ativados[o] = true
		if Jogo.estado == Jogo.Estado.TERMINANDO:
			concluiu = true
			break
	var total: int = Jogo.dados_fase.objetos.size()
	print("%-9s passos=%d maior_x=%d de %d ativados=%d/%d concluiu=%s saltos_de_checkpoint=%s mortes=%d" % [nome, i, maior_x, Jogo.comprimento_fase, ativados.size(), total, concluiu, saltos, mortes.values().reduce(func(a, b): return a + b, 0)])
	Jogo.limpar_fase()
	Jogo.estado = Jogo.Estado.PARADO
	return 0 if concluiu else 1


## Regra simples: pula antes de obstáculos, inimigos e buracos à frente.
func _deve_pular(j: Jogador, _i: int) -> bool:
	if j.apoiado_sobre == null:
		return false
	var chao_a_frente := false
	var frente = j.pos_x + _frente
	for o in Jogo.ativos:
		if o == j or not (o is Personagem):
			continue
		var d = o.pos_x + o.esquerda - j.pos_x
		if o is Chao and not o.colisao.cache.is_empty():
			var c: Array = o.colisao.cache[0]
			if c[0] <= frente and c[2] >= frente and c[1] <= j.pos_y + 5 and c[1] >= j.pos_y - 60:
				chao_a_frente = true
			continue
		if o.get_script().resource_path.ends_with("coletavel.gd") or o.colisao.cache.is_empty():
			continue
		var perto: bool = d > -10 and d < _alcance
		var altura_ok: bool = o.colisao.cache[0][3] < j.pos_y + 120 and o.colisao.cache[0][1] > j.pos_y
		if perto and altura_ok:
			return true
	return not chao_a_frente


func _avancar_checkpoint(j: Jogador, maior_x: float) -> void:
	for c in Jogo.checkpoints:
		if c[0] > maior_x + 5:
			j.apoiado_sobre = null
			j.veloc_y = 0
			j.definir_posicao(c[0], c[1])
			return
