class_name Visual
extends AnimatedSprite2D
## Toca as animações de um personagem/objeto.
## Cada visual fica em arte/<mundo>/<nome>/visual.tscn, separado da lógica do jogo:
## para trocar a arte, basta trocar os quadros nessa cena.

## Fica verdadeiro quando uma animação marcada em "fim_estado" termina.
var fim_do_estado := false


func _ready() -> void:
	animation_finished.connect(_ao_terminar)
	animar(get_meta("animacao_inicial"))


func animar(nome: String) -> void:
	if not sprite_frames.has_animation(nome):
		push_warning("%s não tem a animação '%s'" % [scene_file_path, nome])
		return
	fim_do_estado = false
	play(nome)


## Continua a partir de onde parou (ex.: efeito de pontos que aguarda no início).
func continuar() -> void:
	var seguintes: Dictionary = get_meta("continua", {})
	if seguintes.has(String(animation)):
		animar(seguintes[String(animation)])
	else:
		play()


func parar() -> void:
	pause()


## Espelha em torno do ponto de registro, igual às caixas de colisão.
func espelhar(horizontal: bool, vertical: bool = false) -> void:
	scale = Vector2(-1 if horizontal else 1, -1 if vertical else 1)


func _ao_terminar() -> void:
	var atual := String(animation)
	if atual in get_meta("fim_estado", []):
		fim_do_estado = true
	var proximas: Dictionary = get_meta("proximas", {})
	if proximas.has(atual):
		animar(proximas[atual])
