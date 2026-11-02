extends Tela
## Opções: música, efeitos e, no computador, tela cheia.

const LARGURA := 224.0
const ALTURA := 53.0
const X := 208.0

var _musica: TextureButton
var _efeitos: TextureButton
var _tela_cheia: TextureButton = null


func _ready() -> void:
	fundo_menu()
	var y := 234.0
	_musica = tabua("", Rect2(X, y, LARGURA, ALTURA), _alternar_musica)
	y += ALTURA + 3.0
	_efeitos = tabua("", Rect2(X, y, LARGURA, ALTURA), _alternar_efeitos)
	y += ALTURA + 3.0
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		_tela_cheia = tabua("", Rect2(X, y, LARGURA, ALTURA), _alternar_tela_cheia)
		y += ALTURA + 3.0
	tabua(texto("voltar"), Rect2(X, y, LARGURA, ALTURA), func(): concluida.emit("ok"), true)
	_musica.grab_focus()
	_atualizar()


func _alternar_musica() -> void:
	Som.definir_musica(not Som.musica_ligada)
	Jogo.salvar_preferencias()
	_atualizar()


func _alternar_efeitos() -> void:
	Som.definir_efeitos(not Som.efeitos_ligados)
	Jogo.salvar_preferencias()
	_atualizar()


func _alternar_tela_cheia() -> void:
	if _em_tela_cheia():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_atualizar()


func _em_tela_cheia() -> bool:
	return DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED


func _atualizar() -> void:
	_rotular(_musica, "musica", Som.musica_ligada)
	_rotular(_efeitos, "efeitos", Som.efeitos_ligados)
	if _tela_cheia:
		_rotular(_tela_cheia, "tela_cheia", _em_tela_cheia())


func _rotular(b: TextureButton, chave: String, ligado: bool) -> void:
	for filho in b.get_children():
		if filho is Label:
			filho.text = "%s: %s" % [texto(chave), texto("sim" if ligado else "nao")]
