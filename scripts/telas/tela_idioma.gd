extends Tela
## Escolha de idioma, mostrada só na primeira vez.


func _ready() -> void:
	fundo_menu()
	var pt := tabua("Português", Rect2(186, 240, 268, 68), func(): _escolher("pt"), true)
	tabua("Español", Rect2(208, 320, 224, 53), func(): _escolher("es"))
	pt.grab_focus()


func _escolher(codigo: String) -> void:
	Jogo.idioma = codigo
	Jogo.salvar_preferencias()
	concluida.emit("ok")
