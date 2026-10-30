extends "res://base.gd"
const DIRS = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
var g = []
var cell = 80.0
var ox = 0.0
var oy = 0.0

func build() -> void:
	for i in 64:
		g.append(-1)
	g[27] = 1
	g[28] = 0
	g[35] = 0
	g[36] = 1
	canvas(paint, inp)
	info()

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
	say("%s   %s %d  -  %s %d" % [Games.L("دور ", "Turn: ") + Games.L("الأسود" if turn == 0 else "الأبيض", "Black" if turn == 0 else "White"), Games.L("الأسود", "Black"), g.count(0), Games.L("الأبيض", "White"), g.count(1)])

func inp(e: InputEvent) -> void:
	if over or not my_turn():
		return
	if e is InputEventMouseButton and e.pressed:
		var c = floori((e.position.x - ox) / cell)
		var r = floori((e.position.y - oy) / cell)
		if c < 0 or r < 0 or c > 7 or r > 7:
			return
		if flips(r, c, turn).is_empty():
			return
		act({"r": r, "c": c})

func on_action(_seat: int, d: Dictionary) -> void:
	if over:
		return
	var r = int(d.get("r", 0))
	var c = int(d.get("c", 0))
	var f = flips(r, c, turn)
	if f.is_empty():
		return
	if true:
		g[r * 8 + c] = turn
		for k in f:
			g[k] = turn
		Sound.tone(450 + f.size() * 30, 0.1, 2)
		if has_move(1 - turn):
			turn = 1 - turn
		elif not has_move(turn):
			over_game()
			body.queue_redraw()
			return
		else:
			say("الخصم ما عنده حركة — دورك مرة ثانية")
			body.queue_redraw()
			return
		info()
		body.queue_redraw()

func over_game() -> void:
	var a = g.count(0)
	var b = g.count(1)
	if a == b:
		finish("🤝 تعادل", Color.WHITE)
	else:
		finish(Games.L("فاز " + ("الأسود" if a > b else "الأبيض"), ("Black" if a > b else "White") + " wins") + "  %d : %d" % [a, b])

func paint() -> void:
	cell = minf(body.size.x / 8.0, body.size.y / 8.0)
	ox = (body.size.x - cell * 8) / 2.0
	oy = (body.size.y - cell * 8) / 2.0
	body.draw_rect(Rect2(ox, oy, cell * 8, cell * 8), Color("1e8449"))
	for i in 9:
		body.draw_line(Vector2(ox + i * cell, oy), Vector2(ox + i * cell, oy + 8 * cell), Color(0, 0, 0, 0.5), 2.0)
		body.draw_line(Vector2(ox, oy + i * cell), Vector2(ox + 8 * cell, oy + i * cell), Color(0, 0, 0, 0.5), 2.0)
	for i in 64:
		var c = Vector2(ox + (i % 8 + 0.5) * cell, oy + (i / 8 + 0.5) * cell)
		if g[i] >= 0:
			body.draw_circle(c, cell * 0.4, Color.BLACK if g[i] == 0 else Color.WHITE)
		elif not over and flips(i / 8, i % 8, turn).size() > 0:
			body.draw_circle(c, cell * 0.12, Color(1, 1, 1, 0.45))
