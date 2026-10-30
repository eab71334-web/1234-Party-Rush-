extends "res://base.gd"
const N = 11
var g = []
var cell = 50.0
var ox = 0.0
var oy = 0.0
var last = -1

func build() -> void:
	for i in N * N:
		g.append(-1)
	canvas(paint, inp)
	show_turn()

func layout() -> void:
	cell = minf((body.size.x - 70.0) / (N - 1), (body.size.y - 70.0) / (N - 1))
	ox = (body.size.x - cell * (N - 1)) / 2.0
	oy = (body.size.y - cell * (N - 1)) / 2.0

func paint() -> void:
	layout()
	body.draw_rect(Rect2(ox - cell * 0.7, oy - cell * 0.7, cell * (N - 1) + cell * 1.4, cell * (N - 1) + cell * 1.4), Color("d9a758"))
	for i in N:
		body.draw_line(Vector2(ox, oy + i * cell), Vector2(ox + (N - 1) * cell, oy + i * cell), Color("5c3d12"), 2.0)
		body.draw_line(Vector2(ox + i * cell, oy), Vector2(ox + i * cell, oy + (N - 1) * cell), Color("5c3d12"), 2.0)
	for i in N * N:
		if g[i] >= 0:
			var c = Vector2(ox + (i % N) * cell, oy + (i / N) * cell)
			body.draw_circle(c, cell * 0.42, col(g[i]))
			body.draw_arc(c, cell * 0.42, 0, TAU, 24, Color(0, 0, 0, 0.5), 2.0)
			if i == last:
				body.draw_circle(c, cell * 0.12, Color.WHITE)

func inp(e: InputEvent) -> void:
	if over or not my_turn():
		return
	if e is InputEventMouseButton and e.pressed:
		var c = roundi((e.position.x - ox) / cell)
		var r = roundi((e.position.y - oy) / cell)
		if c < 0 or r < 0 or c >= N or r >= N or g[r * N + c] != -1:
			return
		act({"r": r, "c": c})

func on_action(_seat: int, d: Dictionary) -> void:
	if over:
		return
	var r = int(d.get("r", 0))
	var c = int(d.get("c", 0))
	if r < 0 or c < 0 or r >= N or c >= N or g[r * N + c] != -1:
		return
	if true:
		g[r * N + c] = turn
		last = r * N + c
		Sound.tone(400 + turn * 120, 0.08, 2)
		body.queue_redraw()
		if five(r, c):
			finish("🏆 فاز " + Games.PN[turn], col(turn))
		elif not g.has(-1):
			finish("🤝 تعادل", Color.WHITE)
		else:
			next_turn()

func five(r: int, c: int) -> bool:
	var p = g[r * N + c]
	for d in [[0, 1], [1, 0], [1, 1], [1, -1]]:
		var n = 1
		for s in [1, -1]:
			var rr = r + d[0] * s
			var cc = c + d[1] * s
			while rr >= 0 and rr < N and cc >= 0 and cc < N and g[rr * N + cc] == p:
				n += 1
				rr += d[0] * s
				cc += d[1] * s
		if n >= 5:
			return true
	return false
