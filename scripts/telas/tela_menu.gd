extends Tela
## Menu principal e de pausa.

const TAM := Vector2(100, 24)

var _efeitos: Button
var _musica: Button


func _ready() -> void:
	visual_interface("fundo_menu", Vector2(0, 479))
	var y1 := 372.0
	var y2 := 412.0
	var novo := botao(texto("novo"), Rect2(Vector2(170, y1), TAM), func(): concluida.emit("novo"))
	_efeitos = botao("", Rect2(Vector2(280, y1), TAM), _alternar_efeitos)
	_musica = botao("", Rect2(Vector2(390, y1), TAM), _alternar_musica)
	botao(texto("sair"), Rect2(Vector2(170, y2), TAM), func(): concluida.emit("sair"))
	botao(texto("instrucoes"), Rect2(Vector2(280, y2), TAM), func(): concluida.emit("instrucoes"))
	if Jogo.jogando:
		var c := botao(texto("continuar"), Rect2(Vector2(390, y2), TAM), func(): concluida.emit("continuar"))
		c.grab_focus()
	else:
		novo.grab_focus()
	_atualizar()


func _alternar_efeitos() -> void:
	Som.definir_efeitos(not Som.efeitos_ligados)
	_atualizar()


func _alternar_musica() -> void:
	Som.definir_musica(not Som.musica_ligada)
	_atualizar()


func _atualizar() -> void:
	_efeitos.text = "%s: %s" % [texto("efeitos"), texto("sim" if Som.efeitos_ligados else "nao")]
	_musica.text = "%s: %s" % [texto("musica"), texto("sim" if Som.musica_ligada else "nao")]
