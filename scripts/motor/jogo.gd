extends Node
## Autoload "Jogo": o motor. Carrega fases, roda a lógica a 30 passos por segundo,
## cuida de vidas, pontos, itens, checkpoints, recordes e preferências.

signal fim_de_jogo(venceu: bool, pontos: int, entrou_recordes: bool)
signal fase_concluida
signal pediu_menu
signal hud_mudou

const FASES := ["deserto", "floresta", "neve", "selva", "cidade", "final"]
const MS_POR_PASSO := 1000.0 / 30.0
const TEMPO_FESTEJO_MS := 3000
const MAX_RECORDES := 10
const LIMITE_ATIVACAO := 100
const ARQUIVO_PREFERENCIAS := "user://preferencias.json"

enum Estado { PARADO, JOGANDO, TERMINANDO }

var estado := Estado.PARADO
var jogando := false   # há uma partida em andamento (para o "Continuar" do menu)
var ms := 0.0          # relógio do jogo, avança só durante a partida
var camera := CameraJogo.new()
var jogador: Jogador = null
var fase_atual := 0
var dados_fase: Dictionary = {}
var checkpoints: Array = []
var limite_inferior = 0
var comprimento_fase := 1.0
var cor_semaforo := &"vermelho"
var catalogo: Dictionary = {}
var idioma := ""
var recordes: Array = []
var pontos_finais := 0
var venceu := false

## Preenchidos pela cena principal.
var mundo: Node2D = null
var hud: Hud = null

## Para testes automáticos: quando não é null, substitui o teclado.
var entrada_forcada = null
var esq := false
var dir := false
var cima := false
var baixo := false
var menu := false
var alguma_tecla := false

var objetos: Array = []
var ativos: Array = []
var ativos_paisagem: Array = []
var caminhantes_ativos: Array = []
var _remover: Array = []
var _fundo: Visual = null
var _inicio_festejo := 0.0
var _contador_progresso := 0
var _cena_cache := {}
var _info_cache := {}
var _scripts := {}
var _guardado := {}
var _visuais_novos: Array[Visual] = []


func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	get_viewport().size_changed.connect(_atualizar_largura)
	_atualizar_largura()
	catalogo = _ler_json("res://dados/catalogo.json")
	carregar_preferencias()


func _physics_process(_delta: float) -> void:
	if estado == Estado.JOGANDO:
		passo()
	elif estado == Estado.TERMINANDO:
		if ms - _inicio_festejo > TEMPO_FESTEJO_MS:
			estado = Estado.PARADO
			fase_concluida.emit()
		else:
			passo()


func _atualizar_largura() -> void:
	CameraJogo.largura_real = get_viewport().get_visible_rect().size.x
	if _fundo:
		_fundo.cobrir_largura(CameraJogo.largura_real)


# ------------------------------------------------------------ partida

func nova_partida() -> void:
	fase_atual = 0
	carregar_fase(FASES[0])
	estado = Estado.JOGANDO
	jogando = true


func proxima_fase() -> void:
	fase_atual += 1
	if fase_atual < FASES.size():
		carregar_fase(FASES[fase_atual])
		jogador.placar = _guardado.pontos
		jogador.vidas = _guardado.vidas
		jogador.itens_especiais = _guardado.especiais
		jogador.itens_comuns = _guardado.comuns
		_atualiza_hud()
		estado = Estado.JOGANDO
	else:
		terminar_jogo(true)


func terminar_jogo(ganhou: bool) -> void:
	venceu = ganhou
	pontos_finais = jogador.placar if jogador else 0
	var entrou := entrou_em_recordes(pontos_finais)
	jogando = false
	estado = Estado.PARADO
	limpar_fase()
	fim_de_jogo.emit(ganhou, pontos_finais, entrou)


func termino_de_fase() -> void:
	Som.parar("musica")
	Som.tocar_efeito("snd_llegada")
	_guardado = {"pontos": jogador.placar, "vidas": jogador.vidas,
		"especiais": jogador.itens_especiais, "comuns": jogador.itens_comuns}
	jogador.definir_estado(&"festejando")
	estado = Estado.TERMINANDO
	_inicio_festejo = ms


# ------------------------------------------------------------ fases

func carregar_fase(nome: String) -> void:
	limpar_fase()
	Som.mundo = nome
	dados_fase = _ler_json("res://fases/%s.json" % nome)
	var cor: Array = dados_fase.cor_fundo
	RenderingServer.set_default_clear_color(Color8(int(cor[0]), int(cor[1]), int(cor[2])))
	checkpoints = dados_fase.checkpoints
	limite_inferior = int(dados_fase.limite_inferior)
	cor_semaforo = &""
	camera = CameraJogo.new()
	camera.pos_x = int(dados_fase.camera_inicio[0])
	camera.pos_y = int(dados_fase.camera_inicio[1])
	camera.limite_inferior = limite_inferior
	_fundo = _cena(dados_fase.visuais_fixos.fundo).instantiate()
	_fundo.z_index = -100
	mundo.add_child(_fundo)
	_fundo.position = Vector2(0, CameraJogo.ALTURA_TELA + camera.pos_y)
	_fundo.cobrir_largura(CameraJogo.largura_real)
	_fundo.reset_physics_interpolation()
	if hud:
		hud.preparar_fase(dados_fase)
	for dados in dados_fase.objetos:
		var o := adicionar_objeto(dados)
		if o is Chegada:
			comprimento_fase = float(o.pos_x)
	_contador_progresso = 0
	_atualiza_hud()


func limpar_fase() -> void:
	for o in objetos:
		o.ativo = false
		if o.visual:
			o.visual.queue_free()
			o.visual = null
	objetos = []
	ativos = []
	ativos_paisagem = []
	caminhantes_ativos = []
	_remover = []
	jogador = null
	if _fundo:
		_fundo.queue_free()
		_fundo = null
	Som.parar_tudo()


func adicionar_objeto(dados: Dictionary) -> Objeto:
	var cfg: Dictionary = catalogo[dados.tipo]
	var s: GDScript = _script(cfg.script)
	var o: Objeto = s.new()
	o.iniciar(dados, cfg, self)
	o.pre_calcular()
	if o is Jogador:
		jogador = o
	objetos.append(o)
	if o.dentro_dos_limites(camera):
		_ativar(o)
	return o


## Cria um objeto durante o jogo (usado pelos projéteis).
func criar_projetil(x, y, chave_visual: String, chave_colisao: String, params: Dictionary) -> void:
	adicionar_objeto({"tipo": "projetil", "x": x, "y": y, "z": 1,
		"visual": dados_fase.visuais_fixos[chave_visual], "colisao": chave_colisao, "params": params})


func excluir_depois(o: Objeto) -> void:
	if not _remover.has(o):
		_remover.append(o)


func _excluir(o: Objeto) -> void:
	_desativar(o)
	_remover_visual(o)
	objetos.erase(o)


func _ativar(o: Objeto) -> void:
	if o.ativo:
		return
	o.ativo = true
	if o.visual:
		o.visual.play()
	elif o.cena:
		_criar_visual(o)
	if o.paisagem:
		ativos_paisagem.append(o)
	else:
		ativos.append(o)
		if o is Caminhante:
			caminhantes_ativos.append(o)
	o.ativado()


func _criar_visual(o: Objeto) -> void:
	var v: Visual = o.cena.instantiate()
	v.visible = o.visivel
	v.position = Vector2(-100, -100)
	v.z_index = o.pos_z * 10 + (1 if o is Jogador else 0)
	mundo.add_child(v)
	o.visual = v
	_visuais_novos.append(v)


func _remover_visual(o: Objeto) -> void:
	if o.visual:
		o.visual.queue_free()
		o.visual = null


func _desativar(o: Objeto) -> void:
	if not o.ativo:
		return
	o.ativo = false
	_remover_visual(o)
	if o.paisagem:
		ativos_paisagem.erase(o)
	else:
		ativos.erase(o)
		if o is Caminhante:
			caminhantes_ativos.erase(o)
	o.desativado()


func _atualizar_ativos() -> void:
	var entrando: Array = []
	for o in objetos:
		var dentro: bool = o.dentro_da_tela(camera) if o.paisagem else o.dentro_dos_limites(camera)
		if o.ativo and not dentro and o != jogador:
			_desativar(o)
		elif not o.ativo and dentro:
			entrando.append(o)
	if entrando.size() > 1:
		entrando.sort_custom(func(a, b): return a.limiar_entrada() < b.limiar_entrada())
	for o in entrando:
		_ativar(o)
	_atualizar_previas()


## Mostra, parados, os objetos que já aparecem na tela larga, mas ainda estão fora
## da área das regras. Assim, inimigos e obstáculos agem no mesmo ponto do original.
func _atualizar_previas() -> void:
	for o in objetos:
		if o.ativo or o.cena == null:
			continue
		var tela := camera.para_tela(o.pos_x, o.pos_y, o.pos_z)
		if not o.dentro_da_tela(camera):
			_remover_visual(o)
		else:
			if o.visual == null:
				_criar_visual(o)
				o.visual.pause()
			o.visual.position = tela
			o.visual.visible = o.visivel


# ------------------------------------------------------------ passo do jogo

func passo() -> void:
	ms += MS_POR_PASSO
	_ler_controles()
	for o in ativos.duplicate():
		if o.ativo:
			o.atualizar()
	if jogador == null:
		return
	var mudou := false
	for lista in [ativos, ativos_paisagem]:
		for o in lista:
			if o.pontos != 0 and jogador.pos_x > o.pos_x + o.direita:
				jogador.placar += o.pontos
				o.pontos = 0
				mudou = true
	if mudou:
		_atualiza_hud()
	if estado == Estado.PARADO:
		return
	while not _remover.is_empty():
		_excluir(_remover.pop_front())
	camera.atualizar(jogador)
	_atualizar_ativos()
	_desenhar()
	if _contador_progresso == 0:
		if hud:
			hud.definir_progresso(100.0 - (comprimento_fase - jogador.pos_x) / comprimento_fase * 100.0)
		_contador_progresso = 30
	_contador_progresso -= 1
	if menu:
		estado = Estado.PARADO
		Som.matar_efeitos()
		pediu_menu.emit()


func continuar_partida() -> void:
	estado = Estado.JOGANDO


func _desenhar() -> void:
	for o in ativos:
		if o.visual:
			var tela := camera.para_tela(o.pos_x, o.pos_y, o.pos_z)
			o.visual.position = tela
			o.visual.visible = o.visivel
			if o.visivel:
				o.definir_na_tela(tela.x > 0 and tela.x < CameraJogo.LARGURA_TELA and tela.y > 0 and tela.y < CameraJogo.ALTURA_TELA)
	for o in ativos_paisagem:
		if o.visual:
			o.visual.position = camera.para_tela(o.pos_x, o.pos_y, o.pos_z)
			o.visual.visible = o.visivel
	if _fundo:
		_fundo.position.y = CameraJogo.ALTURA_TELA + camera.pos_y
	for v in _visuais_novos:
		if is_instance_valid(v):
			v.reset_physics_interpolation()
	_visuais_novos.clear()


func _ler_controles() -> void:
	if entrada_forcada != null:
		esq = entrada_forcada.get("esq", false)
		dir = entrada_forcada.get("dir", false)
		cima = entrada_forcada.get("cima", false)
		baixo = entrada_forcada.get("baixo", false)
		menu = entrada_forcada.get("menu", false)
	else:
		esq = Input.is_action_pressed("esquerda")
		dir = Input.is_action_pressed("direita")
		cima = Input.is_action_pressed("pular")
		baixo = Input.is_action_pressed("agachar")
		menu = Input.is_action_pressed("menu")
	alguma_tecla = esq or dir or cima or baixo or menu


# ------------------------------------------------------------ regras

func soma_item(especial: bool) -> void:
	if not especial:
		jogador.placar += 100
		jogador.itens_comuns += 1
		if jogador.itens_comuns >= 6:
			jogador.placar += 300
			jogador.itens_comuns = 0
			soma_item(true)
			if hud:
				hud.efeito_item_especial(jogador.itens_especiais)
		else:
			if hud:
				hud.efeito_pontos(100, jogador.visual.position if jogador.visual else Vector2.ZERO)
			Som.tocar_efeito("snd_item_comum")
		_atualiza_hud()
	else:
		if hud:
			hud.efeito_pontos(600, jogador.visual.position if jogador.visual else Vector2.ZERO)
		jogador.tornar_imune()
		jogador.placar += 600
		jogador.itens_especiais += 1
		_atualiza_hud()
		if jogador.itens_especiais >= 10:
			jogador.placar += 3000
			jogador.itens_especiais = 0
			ganha_vida()
		else:
			Som.tocar_efeito("snd_item_especial")


func ganha_vida() -> void:
	jogador.vidas += 1
	_atualiza_hud()


func perde_vida() -> void:
	jogador.definir_estado(&"morrendo")
	jogador.vidas -= 1
	Som.parar("musica")
	Som.tocar_efeito("snd_pierde_vida")


func comeca_vida() -> void:
	if jogador.vidas < 0:
		terminar_jogo(false)
		return
	_atualiza_hud()
	jogador.definir_estado(&"parado")
	jogador.definir_direcao(jogador.direcao_visual)
	jogador.veloc_x = 0
	jogador.veloc_y = 0
	jogador.tornar_imune()
	Som.tocar_efeito("snd_empieza")
	Som.tocar_musica("snd_backgroundMusic", "musica")
	var ponto: Array = checkpoints[checkpoints.size() - 1]
	for i in checkpoints.size():
		if jogador.pos_x < checkpoints[i][0]:
			ponto = checkpoints[max(i - 1, 0)]
			break
	jogador.definir_posicao(int(ponto[0]), int(ponto[1]))
	if jogador.visual:
		_visuais_novos.append(jogador.visual)


func tocou_hostil() -> void:
	if jogador.imune or jogador.estado == &"festejando" or jogador.estado == &"morrendo":
		return
	jogador.placar = max(jogador.placar - 100, 0)
	if jogador.itens_especiais == 0:
		perde_vida()
	else:
		jogador.itens_especiais -= 1
	jogador.tornar_imune()
	_atualiza_hud()


func tocou_mortal() -> void:
	if jogador.estado != &"morrendo":
		perde_vida()


func _atualiza_hud() -> void:
	if hud and jogador:
		hud.atualizar(jogador)
	hud_mudou.emit()


# ------------------------------------------------------------ recordes e preferências

func entrou_em_recordes(p: int) -> bool:
	if p <= 0:
		return false
	if recordes.size() < MAX_RECORDES:
		return true
	return p > recordes[MAX_RECORDES - 1].pontos


func adicionar_recorde(nome: String, p: int) -> void:
	var i := 0
	while i < recordes.size() and p <= recordes[i].pontos:
		i += 1
	recordes.insert(i, {"nome": nome.substr(0, 20), "pontos": p})
	if recordes.size() > MAX_RECORDES:
		recordes.pop_back()
	salvar_preferencias()


func carregar_preferencias() -> void:
	if not FileAccess.file_exists(ARQUIVO_PREFERENCIAS):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(ARQUIVO_PREFERENCIAS))
	if d is Dictionary:
		idioma = d.get("idioma", "")
		recordes = d.get("recordes", [])


func salvar_preferencias() -> void:
	var f := FileAccess.open(ARQUIVO_PREFERENCIAS, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"idioma": idioma, "recordes": recordes}))


# ------------------------------------------------------------ auxiliares

func _cena(caminho: String) -> PackedScene:
	if not _cena_cache.has(caminho):
		_cena_cache[caminho] = load(caminho)
	return _cena_cache[caminho]


func cena_visual(caminho: String) -> PackedScene:
	return _cena(caminho)


## Tamanho e registro do visual, usados para saber quando o objeto entra na tela.
func info_visual(caminho: String) -> Dictionary:
	if not _info_cache.has(caminho):
		var v: Node = _cena(caminho).instantiate()
		_info_cache[caminho] = {"tamanho": v.get_meta("tamanho"), "registro": v.get_meta("registro")}
		v.free()
	return _info_cache[caminho]


func _script(nome: String) -> GDScript:
	if not _scripts.has(nome):
		_scripts[nome] = load("res://scripts/objetos/%s.gd" % nome)
	return _scripts[nome]


func _ler_json(caminho: String) -> Dictionary:
	var d = JSON.parse_string(FileAccess.get_file_as_string(caminho))
	if d == null:
		push_error("JSON inválido: " + caminho)
		return {}
	return d
