extends Node
## Testa o caminho completo: nova partida, seis fases, vitória, recorde; depois derrota.
## Rode pelo terminal:  godot --headless res://testes/teste_fluxo.tscn -- --sem-intro

var principal
var _erros: Array[String] = []


func _ready() -> void:
	get_tree().create_timer(120.0).timeout.connect(func():
		print("RESULTADO: tempo esgotado")
		get_tree().quit(1))
	principal = load("res://cenas/principal.tscn").instantiate()
	add_child(principal)
	await get_tree().process_frame
	Jogo.idioma = "pt"
	_verificar(principal._tela != null, "menu abriu")
	principal._acao_menu("novo")
	Jogo.estado = Jogo.Estado.PARADO
	Jogo.entrada_forcada = {}
	for i in Jogo.FASES.size():
		_verificar(Jogo.dados_fase.nome == Jogo.FASES[i], "fase %s carregou" % Jogo.FASES[i])
		Jogo.estado = Jogo.Estado.JOGANDO
		for k in 5:
			Jogo.passo()
		Jogo.jogador.placar = 1000 * (i + 1)
		Jogo.soma_item(false)
		var pontos: int = Jogo.jogador.placar
		Jogo.termino_de_fase()
		Jogo.estado = Jogo.Estado.PARADO
		await get_tree().create_timer(0.02).timeout
		if i < Jogo.FASES.size() - 1:
			Jogo.proxima_fase()
			_verificar(Jogo.jogador.placar == pontos, "placar mantido na fase seguinte")
			Jogo.estado = Jogo.Estado.PARADO
		else:
			Jogo.proxima_fase()
			await get_tree().process_frame
			_verificar(Jogo.venceu, "vitória registrada")
			_verificar(principal._tela != null, "tela final abriu")
			_verificar(Jogo.pontos_finais == pontos, "pontos finais")
	principal._tela.concluida.emit("ok")
	await get_tree().process_frame
	Jogo.adicionar_recorde("Teste", Jogo.pontos_finais)
	_verificar(Jogo.recordes[0].nome == "Teste", "recorde gravado")
	principal._tela.concluida.emit("ok")
	await get_tree().process_frame
	principal._tela.concluida.emit("ok")
	await get_tree().process_frame
	principal._acao_menu("novo")
	Jogo.estado = Jogo.Estado.JOGANDO
	var guarda := 0
	while Jogo.jogando and guarda < 5000:
		guarda += 1
		if Jogo.jogador.estado != &"morrendo" and Jogo.jogador.estado != &"idle":
			Jogo.jogador.imune = false
			Jogo.tocou_mortal()
		Jogo.passo()
	_verificar(not Jogo.jogando and not Jogo.venceu, "derrota depois de perder as vidas (%d passos)" % guarda)
	print("RESULTADO: %s" % ("OK" if _erros.is_empty() else str(_erros)))
	get_tree().quit(0 if _erros.is_empty() else 1)


func _verificar(cond: bool, nome: String) -> void:
	print(("ok   " if cond else "FALHOU ") + nome)
	if not cond:
		_erros.append(nome)
