extends "res://base.gd"
const N = 5
var edges = {}
var boxes = {}
var scores = []
var ox = 0.0
var oy = 0.0
var cs = 100.0
var etime = {}
var btime = {}
var last_edge = -1

func build() -> void:
	for i in players:
		scores.append(0)
	canvas(paint, inp)
	show_turn()

func _process(d: float) -> void:
	super._process(d)
	if etime.is_empty() and btime.is_empty():
		return
	for k in etime.keys():
		etime[k] += d
		if etime[k] > 0.6:
			etime.erase(k)
	for k in btime.keys():
		btime[k] += d
		if btime[k] > 0.6:
			btime.erase(k)
	body.queue_redraw()

func layout() -> void:
	cs = minf((body.size.x - 90.0) / N, (body.size.y - 160.0) / N)
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
	var bd = cs * 0.42
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
	etime[i] = 0.0
	last_edge = i
	var got = 0
	for b in adj(i):
		if b[0] > 4 or b[1] > 4:
			continue
		var k = b[0] * 5 + b[1]
		if done(b[0], b[1]) and not boxes.has(k):
			boxes[k] = seat
			btime[k] = 0.0
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
		var s = 1.0
		if btime.has(k):
			s = 1.0 - pow(1.0 - clampf(btime[k] / 0.25, 0.0, 1.0), 3.0)
		var ctr = Vector2(ox + (c + 0.5) * cs, oy + (r + 0.5) * cs)
		var half = (cs - 10.0) / 2.0 * s
		body.draw_style_box(Games.flat(Color(cc.r, cc.g, cc.b, 0.6), 10), Rect2(ctr - Vector2(half, half), Vector2(half, half) * 2.0))
	for i in 60:
		var m = edge_mid(i)
		var a = Vector2(m.x - cs / 2.0, m.y) if i < 30 else Vector2(m.x, m.y - cs / 2.0)
		var b = Vector2(m.x + cs / 2.0, m.y) if i < 30 else Vector2(m.x, m.y + cs / 2.0)
		if edges.has(i):
			var k = 1.0
			if etime.has(i):
				k = clampf(etime[i] / 0.15, 0.0, 1.0)
			if i == last_edge:
				body.draw_line(a, a.lerp(b, k), Color(1, 1, 1, 0.45), 20.0)
			body.draw_line(a, a.lerp(b, k), col(edges[i]), 12.0)
		else:
			body.draw_line(a, b, Color(1, 1, 1, 0.12), 4.0)
	for r in 6:
		for c in 6:
			body.draw_circle(Vector2(ox + c * cs, oy + r * cs), 9.0, Color.WHITE)
	var W = body.size.x - 40.0
	var pw = W / players
	for i in players:
		var rc = Rect2(20.0 + i * pw + 4.0, oy + cs * N + 40.0, pw - 8.0, 70.0)
		body.draw_style_box(Games.style(col(i) if i == turn else col(i).darkened(0.6), 26, 5), rc)
		body.draw_string(f, Vector2(rc.position.x, rc.position.y + 46.0), "%s  %d" % [Games.PN[i], scores[i]], HORIZONTAL_ALIGNMENT_CENTER, rc.size.x, 30, Color.WHITE)
