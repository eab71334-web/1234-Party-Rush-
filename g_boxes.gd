extends "res://base.gd"
const N = 5
var edges = {}
var boxes = {}
var scores = []
var ox = 0.0
var oy = 0.0
var cs = 100.0

func build() -> void:
	for i in players:
		scores.append(0)
	canvas(paint, inp)
	show_turn()

func layout() -> void:
	cs = minf((body.size.x - 90.0) / N, (body.size.y - 130.0) / N)
	ox = (body.size.x - cs * N) / 2.0
	oy = 30.0

func edge_mid(idx: int) -> Vector2:
	if idx < 30:
		return Vector2(ox + (idx % 5 + 0.5) * cs, oy + (idx / 5) * cs)
	var j = idx - 30
	return Vector2(ox + (j % 6) * cs, oy + (j / 6 + 0.5) * cs)

func inp(e: InputEvent) -> void:
	if over or not my_turn() or not (e is InputEventMouseButton and e.pressed):
		return
	layout()
	var best = -1
	var bd = cs * 0.38
	for i in 60:
		if not edges.has(i):
			var d = edge_mid(i).distance_to(e.position)
			if d < bd:
				bd = d
				best = i
	if best >= 0:
		act({"e": best})

func adj(i: int) -> Array:
	var out = []
	if i < 30:
		var r = i / 5
		var c = i % 5
		if r > 0:
			out.append([r - 1, c])
		if r < 5:
			out.append([r, c])
	else:
		var j = i - 30
		var r = j / 6
		var c = j % 6
		if c > 0:
			out.append([r, c - 1])
		if c < 5:
			out.append([r, c])
	return out

func done(r: int, c: int) -> bool:
	return edges.has(r * 5 + c) and edges.has((r + 1) * 5 + c) and edges.has(30 + r * 6 + c) and edges.has(30 + r * 6 + c + 1)

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	var i = int(d.get("e", -1))
	if i < 0 or i > 59 or edges.has(i):
		return
	edges[i] = seat
	var got = 0
	for b in adj(i):
		var k = b[0] * 5 + b[1]
		if done(b[0], b[1]) and not boxes.has(k):
			boxes[k] = seat
			scores[seat] += 1
			got += 1
	Sound.tone(400 + got * 300, 0.08, 2)
	body.queue_redraw()
	if boxes.size() >= 25:
		var best = 0
		for s in players:
			if scores[s] > scores[best]:
				best = s
		if scores.count(scores[best]) > 1:
			finish(Games.L("تعادل", "Draw"), Color.WHITE)
		else:
			finish("فاز " + Games.PN[best], col(best))
	elif got == 0:
		next_turn()
	else:
		show_turn()

func paint() -> void:
	layout()
	var f = ThemeDB.fallback_font
	for k in boxes.keys():
		var r = k / 5
		var c = k % 5
		var cc = col(boxes[k])
		body.draw_rect(Rect2(ox + c * cs + 5, oy + r * cs + 5, cs - 10, cs - 10), Color(cc.r, cc.g, cc.b, 0.55))
	for i in 60:
		var m = edge_mid(i)
		var a = Vector2(m.x - cs / 2.0, m.y) if i < 30 else Vector2(m.x, m.y - cs / 2.0)
		var b = Vector2(m.x + cs / 2.0, m.y) if i < 30 else Vector2(m.x, m.y + cs / 2.0)
		if edges.has(i):
			body.draw_line(a, b, col(edges[i]), 12.0)
		else:
			body.draw_line(a, b, Color(1, 1, 1, 0.12), 4.0)
	for r in 6:
		for c in 6:
			body.draw_circle(Vector2(ox + c * cs, oy + r * cs), 9.0, Color.WHITE)
	var s = ""
	for i in players:
		s += "%s: %d    " % [Games.PN[i], scores[i]]
	body.draw_string(f, Vector2(0, oy + cs * N + 70), s, HORIZONTAL_ALIGNMENT_CENTER, body.size.x, 38, Color.WHITE)
