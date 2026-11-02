extends Tela


func _ready() -> void:
	imagem_idioma("instrucoes", Vector2(320, 240))
	botao(texto("voltar"), Rect2(542, 443, 90, 30), func(): concluida.emit("ok")).grab_focus()
