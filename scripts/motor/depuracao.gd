extends Node2D
## F1 durante o jogo mostra as caixas de colisão (só na versão de depuração).


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	for o in Jogo.ativos:
		if o is Personagem:
			for c in o.colisao.cache:
				var a: Vector2 = Jogo.camera.para_tela(c[0], c[1], o.pos_z)
				var b: Vector2 = Jogo.camera.para_tela(c[2], c[3], o.pos_z)
				draw_rect(Rect2(a, b - a), Color.RED if o is Jogador else Color.YELLOW, false, 1.0)
