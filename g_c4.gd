extends "res://base.gd"
const C = 7
const R = 6
var grid = []
var cell = 90.0
var ox = 0.0
var oy = 0.0
var fall = null
var busy = false
var win_cells = []
var last = -1
var tt = 0.0
var hover = -1

func build() -> void:
	for i in C * R:
		grid.append(-1)
	canvas(paint, inp)
	show_turn()

func _process(d: float) -> void:
	super._process(d)
	tt += d
	if hover >= 0 or not win_cells.is_empty():
		body.queue_redraw()

func layout() -> void:
	cell = minf((body.size.x - 40.0) / C, (body.size.y - 60.0) / (R + 0.9))
	var top_pad = cell * 0.9
	ox = (body.size.x - cell * C) / 2.0
	oy = top_pad + (body.size.y - top_pad - cell * R) / 2.0

func paint() -> void:
	layout()
	if hover >= 0:
		body.draw_rect(Rect2(ox + hover * cell, oy - 14, cell, cell * R + 28), Color(1, 1, 1, 0.1))
		var gc = col(turn)
		body.draw_circle(Vector2(ox + (hover + 0.5) * cell, oy - cell * 0.5), cell * 0.38, Color(gc.r, gc.g, gc.b, 0.85))
	body.draw_style_box(Games.style(Color("2b57d6"), 34, 12), Rect2(ox - 14, oy - 14, cell * C + 28, cell * R + 28))
	for r in R:
		for c in C:
			var p = grid[r * C + c]
			var colr = Color("10215e") if p < 0 else col(p)
			var cc = Vector2(ox + (c + 0.5) * cell, oy + (r + 0.5) * cell)
			body.draw_circle(cc, cell * 0.4, colr)
			if p >= 0:
				body.draw_circle(cc + Vector2(-cell * 0.1, -cell * 0.1), cell * 0.1, Color(1, 1, 1, 0.35))
				body.draw_arc(cc, cell * 0.28, 0, TAU, 24, Color(0, 0, 0, 0.18), cell * 0.05)
			if r * C + c == last and p >= 0:
				body.draw_circle(cc, cell * 0.08, Color.WHITE)
	for k in win_cells:
		var cw = Vector2(ox + (k % C + 0.5) * cell, oy + (k / C + 0.5) * cell)
		body.draw_arc(cw, cell * 0.44 + sin(tt * 8.0) * cell * 0.03, 0, TAU, 32, Color.WHITE, 5.0)
	if fall != null:
		body.draw_circle(Vector2(ox + (fall[0] + 0.5) * cell, fall[1]), cell * 0.4, col(fall[2]))

func set_fall(y: float) -> void:
	if fall != null:
		fall[1] = y
	body.queue_redraw()

func col_at(x: float) -> int:
	var c = floori((x - ox) / cell)
	return c if (c >= 0 and c < C) else -1

func inp(e: InputEvent) -> void:
	if over or busy or not my_turn():
		hover = -1
		return
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			hover = col_at(e.position.x)
		else:
			var c = hover
			hover = -1
			if c >= 0 and c == col_at(e.position.x):
				act({"c": c})
			body.queue_redraw()
	elif e is InputEventMouseMotion and hover >= 0 and e.button_mask != 0:
		hover = col_at(e.position.x)

func is_busy() -> bool:
	return busy

func on_action(seat: int, d: Dictionary) -> void:
	if over or busy or (online and seat != turn):
		return
	var c = int(d.get("c", 0))
	if c < 0 or c >= C:
		return
	drop(c)

func drop(c: int) -> void:
	var r = -1
	for k in range(R - 1, -1, -1):
		if grid[k * C + c] == -1:
			r = k
			break
	if r < 0:
		Sound.tone(150, 0.1, 1)
		return
	busy = true
	fall = [c, oy - cell / 2.0, turn]
	var tw = create_tween()
	tw.tween_method(set_fall, oy - cell / 2.0, oy + (r + 0.5) * cell, 0.28 + 0.05 * r).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tw.finished
	fall = null
	grid[r * C + c] = turn
	last = r * C + c
	Sound.tone(300 + turn * 120, 0.1, 0)
	body.queue_redraw()
	busy = false
	win_cells = four(r, c)
	if not win_cells.is_empty():
		finish("🏆 فاز " + Games.PN[turn], col(turn))
	elif not grid.has(-1):
		finish("🤝 تعادل", Color.WHITE)
	else:
		next_turn()
	pump()

func four(r: int, c: int) -> Array:
	var p = grid[r * C + c]
	for d in [[0, 1], [1, 0], [1, 1], [1, -1]]:
		var line = [r * C + c]
		for s in [1, -1]:
			var rr = r + d[0] * s
			var cc = c + d[1] * s
			while rr >= 0 and rr < R and cc >= 0 and cc < C and grid[rr * C + cc] == p:
				line.append(rr * C + cc)
				rr += d[0] * s
				cc += d[1] * s
		if line.size() >= 4:
			return line
	return []
