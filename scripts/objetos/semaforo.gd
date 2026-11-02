extends Objeto

var tempo_vermelho = 4000
var tempo_verde = 4000
var _inicio := 0.0


func preparar() -> void:
	tempo_vermelho = parametro("tempo_vermelho_ms", 4000)
	tempo_verde = parametro("tempo_verde_ms", 4000)


func _mudar(novo: StringName) -> void:
	if estado != novo:
		jogo.cor_semaforo = novo
		if visual:
			visual.animar(String(novo))
		estado = novo


func estado_idle() -> void:
	_mudar(&"vermelho")
	_inicio = jogo.ms


func estado_vermelho() -> void:
	if jogo.ms - _inicio > tempo_vermelho:
		_inicio = jogo.ms
		_mudar(&"verde")


func estado_verde() -> void:
	if jogo.ms - _inicio > tempo_verde:
		_inicio = jogo.ms
		_mudar(&"vermelho")
