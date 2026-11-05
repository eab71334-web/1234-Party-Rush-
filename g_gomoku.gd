extends "res://base.gd"
const N = 11
var g = []
var cell = 50.0
var ox = 0.0
var oy = 0.0
var last = -1
var win_line = []
var drop_t = 1.0
var tt = 0.0

func build() -> void:
	for i in N * N:
		g.append(-1)
	canvas(paint, inp)
	show_turn()

func _process(d: float) -> void:
	super._process(d)
	tt += d
	if drop_t < 1.0:
		drop_t = minf(1.0, drop_t + d / 0.2)
		body.queue_redraw()
	elif not win_line.is_empty():
		body.queue_redraw()

func layout() -> void:
	cell = minf((body.size.x - 70.0) / (N - 1), (body.size.y - 70.0) / (N - 1))
	ox = (body.size.x - cell * (N - 1)) / 2.0
	oy = (body.size.y - cell * (N - 1)) / 2.0

func paint() -> void:
	layout()
	var wood = Rect2(ox - cell * 0.7, oy - cell * 0.7, cell * (N - 1) + cell * 1.4, cell * (N - 1) + cell * 1.4)
	body.draw_style_box(Games.style(Color("d9a758"), 22, 8), wood)
	for i in N:
		body.draw_line(Vector2(ox, oy + i * cell), Vector2(ox + (N - 1) * cell, oy + i * cell), Color("5c3d12"), 2.0)
		body.draw_line(Vector2(ox + i * cell, oy), Vector2(ox + i * cell, oy + (N - 1) * cell), Color("5c3d12"), 2.0)
	for sp in [[2, 2], [2, 8], [8, 2], [8, 8], [5, 5]]:
		body.draw_circle(Vector2(ox + sp[0] * cell, oy + sp[1] * cell), cell * 0.1, Color("5c3d12"))
	for i in N * N:
		if g[i] >= 0:
			var c = Vector2(ox + (i % N) * cell, oy + (i / N) * cell)
			var rad = cell * 0.42
			if i == last:
				rad *= 1.0 + 0.5 * pow(1.0 - drop_t, 2.0)
			body.draw_circle(c + Vector2(2, 3), rad, Color(0, 0, 0, 0.3))
			body.draw_circle(c, rad, col(g[i]))
			body.draw_arc(c, rad, 0, TAU, 24, Color(0, 0, 0, 0.45), 2.0)
			body.draw_circle(c + Vector2(-rad * 0.3, -rad * 0.3), rad * 0.22, Color(1, 1, 1, 0.4))
			if i == last and win_line.is_empty():
				body.draw_circle(c, cell * 0.1, Color.WHITE)
	for k in win_line:
		var cw = Vector2(ox + (k % N) * cell, oy + (k / N) * cell)
		body.draw_arc(cw, cell * 0.5 + sin(tt * 8.0) * cell * 0.04, 0, TAU, 28, Color.WHITE, 4.0)

func inp(e: InputEvent) -> void:
	if over or not my_turn():
		return
	if e is InputEventMouseButton and e.pressed:
		var c = roundi((e.position.x - ox) / cell)
		var r = roundi((e.position.y - oy) / cell)
		if c < 0 or r < 0 or c >= N or r >= N or g[r * N + c] != -1:
			return
		act({"r": r, "c": c})

func on_action(seat: int, d: Dictionary) -> void:
	if over or (online and seat != turn):
		return
	var r = int(d.get("r", 0))
	var c = int(d.get("c", 0))
	if r < 0 or c < 0 or r >= N or c >= N or g[r * N + c] != -1:
		return
	g[r * N + c] = turn
	last = r * N + c
	drop_t = 0.0
	Sound.tone(400 + turn * 120, 0.08, 2)
	body.queue_redraw()
	win_line = five(r, c)
	if not win_line.is_empty():
		finish("🏆 فاز " + Games.PN[turn], col(turn))
	elif not g.has(-1):
		finish("🤝 تعادل", Color.WHITE)
	else:
		next_turn()

func five(r: int, c: int) -> Array:
	var p = g[r * N + c]
	for d in [[0, 1], [1, 0], [1, 1], [1, -1]]:
		var line = [r * N + c]
		for s in [1, -1]:
			var rr = r + d[0] * s
			var cc = c + d[1] * s
			while rr >= 0 and rr < N and cc >= 0 and cc < N and g[rr * N + cc] == p:
				line.append(rr * N + cc)
				rr += d[0] * s
				cc += d[1] * s
		if line.size() >= 5:
			return line
	return []
