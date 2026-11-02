class_name Visual
extends AnimatedSprite2D
## Toca as animações de um personagem/objeto.
## Cada visual fica em arte/<mundo>/<nome>/visual.tscn, separado da lógica do jogo:
## para trocar a arte, basta trocar os quadros nessa cena.

## Fica verdadeiro quando uma animação marcada em "fim_estado" termina.
var fim_do_estado := false
## Tamanho de exibição da arte. Para arte em 2x, use metadata/escala_arte = 0.5 na cena.
var _escala := 1.0


func _ready() -> void:
	_escala = get_meta("escala_arte", 1.0)
	offset /= _escala
	scale = Vector2(_escala, _escala)
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
	scale = Vector2(-_escala if horizontal else _escala, -_escala if vertical else _escala)
	reset_physics_interpolation()


## Estica o fundo para cobrir a largura da tela.
func cobrir_largura(largura: float) -> void:
	scale.x = _escala * max(1.0, largura / get_meta("tamanho").x)


func _ao_terminar() -> void:
	var atual := String(animation)
	if atual in get_meta("fim_estado", []):
		fim_do_estado = true
	var proximas: Dictionary = get_meta("proximas", {})
	if proximas.has(atual):
		animar(proximas[atual])
