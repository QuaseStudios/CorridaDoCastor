extends Node
## Cena principal: liga o motor às telas e controla o fluxo do jogo.

const DURACAO_FADE := 0.35

@onready var mundo: Node2D = $Mundo
@onready var hud: Hud = $Hud
@onready var telas: CanvasLayer = $Telas
@onready var fade: ColorRect = $Fade/Cor
@onready var depuracao: Node2D = $Depuracao

var _tela: Tela = null


func _ready() -> void:
	Jogo.mundo = mundo
	Jogo.hud = hud
	Jogo.pediu_menu.connect(_abrir_menu)
	Jogo.fase_concluida.connect(_trocar_fase)
	Jogo.fim_de_jogo.connect(_ao_fim_de_jogo)
	hud.visible = false
	if "--sem-intro" in OS.get_cmdline_user_args():
		_abrir_menu()
	elif Jogo.idioma == "":
		_mostrar("res://scripts/telas/tela_idioma.gd", func(_r): _abrir_intro())
	else:
		_abrir_intro()


func _mostrar(script_tela: String, ao_concluir: Callable, config: Callable = Callable()) -> void:
	if _tela:
		_tela.queue_free()
		_tela = null
	var t: Tela = load(script_tela).new()
	if config.is_valid():
		config.call(t)
	t.concluida.connect(ao_concluir, CONNECT_ONE_SHOT)
	telas.add_child(t)
	_tela = t


func _fechar_tela() -> void:
	if _tela:
		_tela.queue_free()
		_tela = null


func _abrir_intro() -> void:
	_mostrar("res://scripts/telas/tela_intro.gd", func(_r): _abrir_menu_do_preto())


func _abrir_menu_do_preto() -> void:
	_abrir_menu()
	fade.color.a = 1.0
	create_tween().tween_property(fade, "color:a", 0.0, 0.6)


func _abrir_menu() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	if not Jogo.jogando:
		Som.mundo = "comum"
		Som.tocar_musica("snd_backgroundMusic", "musica")
	_mostrar("res://scripts/telas/tela_menu.gd", _acao_menu)


func _acao_menu(acao: String) -> void:
	match acao:
		"novo":
			_fechar_tela()
			hud.visible = true
			Jogo.nova_partida()
		"continuar":
			_fechar_tela()
			var cor: Array = Jogo.dados_fase.cor_fundo
			RenderingServer.set_default_clear_color(Color8(int(cor[0]), int(cor[1]), int(cor[2])))
			Jogo.continuar_partida()
		"instrucoes":
			_mostrar("res://scripts/telas/tela_instrucoes.gd", func(_r): _abrir_menu())
		"opcoes":
			_mostrar("res://scripts/telas/tela_opcoes.gd", func(_r): _abrir_menu())
		"sair":
			Jogo.salvar_preferencias()
			get_tree().quit()


func _trocar_fase() -> void:
	var t := create_tween()
	t.tween_property(fade, "color:a", 1.0, DURACAO_FADE)
	t.tween_callback(Jogo.proxima_fase)
	t.tween_property(fade, "color:a", 0.0, DURACAO_FADE)


func _ao_fim_de_jogo(venceu: bool, _pontos: int, entrou: bool) -> void:
	hud.visible = false
	RenderingServer.set_default_clear_color(Color.BLACK)
	fade.color.a = 0.0
	_mostrar("res://scripts/telas/tela_final.gd", func(_r): _apos_final(entrou), func(t): t.venceu = venceu)


func _apos_final(entrou: bool) -> void:
	if entrou:
		_mostrar("res://scripts/telas/tela_grava.gd", func(_r): _abrir_recordes())
	elif not Jogo.recordes.is_empty():
		_abrir_recordes()
	else:
		_abrir_menu()


func _abrir_recordes() -> void:
	_mostrar("res://scripts/telas/tela_recordes.gd", func(_r): _abrir_menu())


## F11 alterna a tela cheia. Os outros atalhos são de teste e só funcionam pelo editor.
func _unhandled_key_input(evento: InputEvent) -> void:
	if evento.is_pressed() and evento.keycode == KEY_F11:
		_alternar_tela_cheia()
		return
	if not OS.is_debug_build() or not evento.is_pressed() or not Jogo.jogando:
		return
	match evento.keycode:
		KEY_F1:
			depuracao.visible = not depuracao.visible
		KEY_F2:
			_proximo_checkpoint()
		KEY_F3:
			Jogo.termino_de_fase()


func _alternar_tela_cheia() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _proximo_checkpoint() -> void:
	var j := Jogo.jogador
	for c in Jogo.checkpoints:
		if j.pos_x < c[0]:
			j.definir_posicao(c[0], c[1])
			Jogo.camera.pos_x = c[0] - 150
			return
