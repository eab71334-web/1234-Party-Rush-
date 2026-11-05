extends "res://base.gd"
const DIRS = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
var g = []
var cell = 80.0
var ox = 0.0
var oy = 0.0
var fl = {}
var last = -1
var tt = 0.0

func build() -> void:
	for i in 64:
		g.append(-1)
	g[27] = 1
	g[28] = 0
	g[35] = 0
	g[36] = 1
	canvas(paint, inp)
	info()

func _process(d: float) -> void:
	super._process(d)
	tt += d
	for k in fl.keys():
		fl[k][0] += d
		if fl[k][0] >= 0.35:
			fl.erase(k)
	if not over or not fl.is_empty():
		body.queue_redraw()

func flips(r: int, c: int, p: int) -> Array:
	var out = []
	if g[r * 8 + c] != -1:
		return out
	for d in DIRS:
		var line = []
		var rr = r + d[0]
		var cc = c + d[1]
		while rr >= 0 and rr < 8 and cc >= 0 and cc < 8 and g[rr * 8 + cc] == 1 - p:
			line.append(rr * 8 + cc)
			rr += d[0]
			cc += d[1]
		if rr >= 0 and rr < 8 and cc >= 0 and cc < 8 and g[rr * 8 + cc] == p and line.size() > 0:
			out.append_array(line)
	return out

func has_move(p: int) -> bool:
	for i in 64:
		if flips(i / 8, i % 8, p).size() > 0:
			return true
	return false

func info() -> void:
	say("%s   %s %d  -  %s %d" % [Games.L("دور ", "Turn: ") + Games.L("الأسود" if turn == 0 else "الأبيض", "Black" if turn == 0 else "White"), Games.L("الأسود", "Black"), g.count(0), Games.L("الأبيض", "White"), g.count(1)], Color.WHITE)

func inp(e: InputEvent) -> void:
	if over or not my_turn():
		return
	if e is InputEventMouseButton and e.pressed:
		var c = floori((e.position.x - ox) / cell)
		var r = floori((e.position.y - oy) / cell)
		if c < 0 or r < 0 or c > 7 or r > 7:
			return
		if flips(r, c, turn).is_empty():
			Sound.tone(150, 0.08, 1)
			return
		act({"r": r, "c": c})

func on_action(seat: int, d: Dictionary) -> void:
	if over or (online and seat != turn):
		return
	var r = int(d.get("r", 0))
	var c = int(d.get("c", 0))
	if r < 0 or c < 0 or r > 7 or c > 7:
		return
	var f = flips(r, c, turn)
	if f.is_empty():
		return
	g[r * 8 + c] = turn
	last = r * 8 + c
	fl[last] = [0.0, "new"]
	for k in f:
		g[k] = turn
		fl[k] = [0.0, "flip"]
	Sound.tone(450 + f.size() * 30, 0.1, 2)
	if has_move(1 - turn):
		turn = 1 - turn
	elif not has_move(turn):
		over_game()
		return
	else:
		say("الخصم ما عنده حركة — دورك مرة ثانية")
		return
	info()

func over_game() -> void:
	var a = g.count(0)
	var b = g.count(1)
	if a == b:
		finish("🤝 تعادل", Color.WHITE)
	else:
		finish(Games.L("فاز " + ("الأسود" if a > b else "الأبيض"), ("Black" if a > b else "White") + " wins") + "  %d : %d" % [a, b])

func paint() -> void:
	cell = minf(body.size.x / 8.0 - 4.0, body.size.y / 8.0 - 4.0)
	ox = (body.size.x - cell * 8) / 2.0
	oy = (body.size.y - cell * 8) / 2.0
	body.draw_style_box(Games.style(Color("14532d"), 24, 0), Rect2(ox - 12, oy - 12, cell * 8 + 24, cell * 8 + 24))
	for i in 64:
		var rc = Rect2(ox + (i % 8) * cell, oy + (i / 8) * cell, cell, cell)
		body.draw_rect(rc, Color("1e8449") if ((i % 8) + (i / 8)) % 2 == 0 else Color("1a7a42"))
	for i in 9:
		body.draw_line(Vector2(ox + i * cell, oy), Vector2(ox + i * cell, oy + 8 * cell), Color(0, 0, 0, 0.35), 2.0)
		body.draw_line(Vector2(ox, oy + i * cell), Vector2(ox + 8 * cell, oy + i * cell), Color(0, 0, 0, 0.35), 2.0)
	var show_hints = (not over) and my_turn()
	for i in 64:
		var c = Vector2(ox + (i % 8 + 0.5) * cell, oy + (i / 8 + 0.5) * cell)
		if g[i] >= 0:
			var rad = cell * 0.4
			var now = Color("1b1b22") if g[i] == 0 else Color("f5f6fa")
			if fl.has(i):
				var k = clampf(fl[i][0] / 0.35, 0.0, 1.0)
				if fl[i][1] == "new":
					rad *= 1.0 - pow(1.0 - k, 3.0)
					body.draw_circle(c, rad, now)
				else:
					var sx = maxf(absf(cos(k * PI)), 0.06)
					var shown = now if k > 0.5 else (Color("f5f6fa") if g[i] == 0 else Color("1b1b22"))
					body.draw_set_transform(c, 0.0, Vector2(sx, 1.0))
					body.draw_circle(Vector2.ZERO, rad, shown)
					body.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				body.draw_circle(c + Vector2(0, cell * 0.03), rad, Color(0, 0, 0, 0.3))
				body.draw_circle(c, rad, now)
				body.draw_circle(c + Vector2(-rad * 0.3, -rad * 0.3), rad * 0.25, Color(1, 1, 1, 0.18 if g[i] == 0 else 0.5))
			if i == last:
				body.draw_arc(c, cell * 0.44, 0, TAU, 28, Color("ffd32a"), 3.0)
		elif show_hints and flips(i / 8, i % 8, turn).size() > 0:
			body.draw_circle(c, cell * 0.12 + sin(tt * 4.0) * cell * 0.015, Color(1, 1, 1, 0.5))
