extends Tela
## Menu principal e de pausa. "Continuar" só aparece com uma partida em andamento.

const X_LARANJA := 186.0
const X_MARROM := 208.0
const LARGURA_LARANJA := 268.0
const LARGURA_MARROM := 224.0


func _ready() -> void:
	fundo_menu()
	var acoes := [{"texto": "novo", "acao": "novo", "icone": "triangulo"}]
	if Jogo.jogando:
		acoes.append({"texto": "continuar", "acao": "continuar", "icone": "triangulo"})
	acoes.append({"texto": "instrucoes", "acao": "instrucoes", "icone": "livro"})
	acoes.append({"texto": "opcoes", "acao": "opcoes", "icone": "engrenagem"})
	acoes.append({"texto": "sair", "acao": "sair", "icone": "sair"})

	# A primeira tábua é a laranja. Com cinco botões, todas ficam mais baixas.
	var altura_laranja := 56.0 if Jogo.jogando else 68.0
	var altura_marrom := 42.0 if Jogo.jogando else 53.0
	var folga := 3.0
	var y := 228.0
	var botoes: Array[TextureButton] = []
	for i in acoes.size():
		var a: Dictionary = acoes[i]
		var rect := Rect2(X_MARROM, y, LARGURA_MARROM, altura_marrom)
		if i == 0:
			rect = Rect2(X_LARANJA, y, LARGURA_LARANJA, altura_laranja)
		var acao: String = a.acao
		botoes.append(tabua(texto(a.texto), rect, func(): concluida.emit(acao), i == 0, a.icone))
		y += rect.size.y + folga
	# Na pausa, o foco começa em "Continuar".
	botoes[1 if Jogo.jogando else 0].grab_focus()
