extends "res://base.gd"
const C = 7
const R = 6
var grid = []
var cell = 90.0
var ox = 0.0
var oy = 0.0
var fall = null
var busy = false

func build() -> void:
	for i in C * R:
		grid.append(-1)
	canvas(paint, inp)
	show_turn()

func layout() -> void:
	cell = minf((body.size.x - 40.0) / C, (body.size.y - 80.0) / R)
	ox = (body.size.x - cell * C) / 2.0
	oy = (body.size.y - cell * R) / 2.0

func paint() -> void:
	layout()
	body.draw_style_box(Games.style(Color("2b57d6"), 34, 12), Rect2(ox - 14, oy - 14, cell * C + 28, cell * R + 28))
	for r in R:
		for c in C:
			var p = grid[r * C + c]
			var colr = Color("10215e") if p < 0 else col(p)
			var cc = Vector2(ox + (c + 0.5) * cell, oy + (r + 0.5) * cell)
			body.draw_circle(cc, cell * 0.4, colr)
			if p >= 0:
				body.draw_circle(cc + Vector2(-cell * 0.1, -cell * 0.1), cell * 0.1, Color(1, 1, 1, 0.35))
	if fall != null:
		body.draw_circle(Vector2(ox + (fall[0] + 0.5) * cell, fall[1]), cell * 0.4, col(fall[2]))

func set_fall(y: float) -> void:
	fall[1] = y
	body.queue_redraw()

func inp(e: InputEvent) -> void:
	if over or busy or not my_turn():
		return
	if e is InputEventMouseButton and e.pressed:
		if e.position.x < ox:
			return
		var c = int((e.position.x - ox) / cell)
		if c >= 0 and c < C:
			act({"c": c})

func is_busy() -> bool:
	return busy

func on_action(_seat: int, d: Dictionary) -> void:
	if over or busy:
		return
	drop(int(d.get("c", 0)))

func drop(c: int) -> void:
	var r = -1
	for k in range(R - 1, -1, -1):
		if grid[k * C + c] == -1:
			r = k
			break
	if r < 0:
		return
	busy = true
	fall = [c, oy - cell / 2.0, turn]
	var tw = create_tween()
	tw.tween_method(set_fall, oy - cell / 2.0, oy + (r + 0.5) * cell, 0.12 + 0.06 * r)
	await tw.finished
	fall = null
	grid[r * C + c] = turn
	Sound.tone(300 + turn * 120, 0.1, 0)
	body.queue_redraw()
	busy = false
	if four(r, c):
		finish("🏆 فاز " + Games.PN[turn], col(turn))
	elif not grid.has(-1):
		finish("🤝 تعادل", Color.WHITE)
	else:
		next_turn()
	pump()

func four(r: int, c: int) -> bool:
	var p = grid[r * C + c]
	for d in [[0, 1], [1, 0], [1, 1], [1, -1]]:
		var n = 1
		for s in [1, -1]:
			var rr = r + d[0] * s
			var cc = c + d[1] * s
			while rr >= 0 and rr < R and cc >= 0 and cc < C and grid[rr * C + cc] == p:
				n += 1
				rr += d[0] * s
				cc += d[1] * s
		if n >= 4:
			return true
	return false
