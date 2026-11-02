extends Node
## Autoload "Som": mixer de 8 canais, com música e efeitos.
## Os sons ficam em sons/<mundo>/ (procurados primeiro) e sons/comum/.

const CANAIS := 8
const SONS_EM_LOOP := ["snd_backgroundMusic", "snd_corriendo"]

var efeitos_ligados := true
var musica_ligada := true
var mundo := "comum"

var _canais: Array[AudioStreamPlayer] = []
var _info: Array[Dictionary] = []
var _cache := {}


func _ready() -> void:
	for i in CANAIS:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_canais.append(p)
		_info.append({"id": "", "nome": "", "tipo": ""})


func carregar(nome: String) -> AudioStream:
	var chave := mundo + "/" + nome
	if _cache.has(chave):
		return _cache[chave]
	var stream: AudioStream = null
	for pasta in [mundo, "comum", "intro"]:
		for ext in ["mp3", "wav"]:
			var caminho := "res://sons/%s/%s.%s" % [pasta, nome, ext]
			if ResourceLoader.exists(caminho):
				stream = load(caminho)
				break
		if stream != null:
			break
	if stream != null and nome in SONS_EM_LOOP:
		stream = stream.duplicate()
		if stream is AudioStreamMP3:
			stream.loop = true
		elif stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_end = int(stream.get_length() * stream.mix_rate)
	_cache[chave] = stream
	return stream


func tocar_musica(nome: String, id: String) -> void:
	_tocar(nome, id, "musica", not musica_ligada)


func tocar_efeito(nome: String, id: String = "") -> void:
	if efeitos_ligados:
		_tocar(nome, id, "efeito", false)


func parar(id: String) -> void:
	var c := _canal_do_id(id)
	if c != -1:
		_liberar(c)


func pausar(id: String) -> void:
	var c := _canal_do_id(id)
	if c != -1:
		_canais[c].stream_paused = true


func definir_musica(ligada: bool) -> void:
	musica_ligada = ligada
	_pausar_tipo("musica", not ligada)


func definir_efeitos(ligados: bool) -> void:
	efeitos_ligados = ligados
	_pausar_tipo("efeito", not ligados)


func matar_efeitos() -> void:
	for i in CANAIS:
		if _info[i].tipo == "efeito":
			_liberar(i)


func parar_tudo() -> void:
	for i in CANAIS:
		_liberar(i)


func _tocar(nome: String, id: String, tipo: String, comecar_pausado: bool) -> void:
	var c := -1
	if id != "":
		c = _canal_do_id(id)
		if c != -1 and tipo == "musica" and _info[c].nome == nome and _canais[c].playing and not _canais[c].stream_paused:
			return
		if c != -1 and _info[c].nome == nome and _canais[c].stream_paused and not comecar_pausado:
			_canais[c].stream_paused = false
			return
	if c == -1:
		c = _canal_livre()
	if c == -1:
		return
	var stream := carregar(nome)
	if stream == null:
		push_warning("Som não encontrado: " + nome)
		return
	_info[c] = {"id": id, "nome": nome, "tipo": tipo}
	_canais[c].stream = stream
	_canais[c].stream_paused = false
	_canais[c].play()
	if comecar_pausado:
		_canais[c].stream_paused = true


func _liberar(c: int) -> void:
	_canais[c].stop()
	_canais[c].stream_paused = false
	_info[c] = {"id": "", "nome": "", "tipo": ""}


func _pausar_tipo(tipo: String, pausado: bool) -> void:
	for i in CANAIS:
		if _info[i].tipo == tipo and _canais[i].playing:
			_canais[i].stream_paused = pausado


func _canal_do_id(id: String) -> int:
	if id == "":
		return -1
	for i in CANAIS:
		if _info[i].id == id:
			return i
	return -1


func _canal_livre() -> int:
	for i in CANAIS:
		if not _canais[i].playing:
			_info[i] = {"id": "", "nome": "", "tipo": ""}
			return i
	return -1
