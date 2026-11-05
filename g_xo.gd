extends "res://base.gd"
const L = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
var cells = []
var bs = []
var thinking = false

func build() -> void:
	var g = center_grid(3, 16)
	for i in 9:
		cells.append("")
		var b = Games.btn("", Color("3a2a7a"), 200, 110)
		b.custom_minimum_size = Vector2(200, 200)
		b.pressed.connect(play.bind(i))
		g.add_child(b)
		bs.append(b)
		Games.pop(b, i * 0.03)
	show_turn()

func play(i: int) -> void:
	if over or thinking or cells[i] != "" or not my_turn():
		return
	if players == 1 and turn == 1:
		return
	act({"i": i})

func on_action(seat: int, d: Dictionary) -> void:
	if over or (online and seat != turn):
		return
	var i = int(d.get("i", 0))
	if i < 0 or i > 8:
		return
	if not put(i):
		return
	if players == 1 and not online and not over:
		thinking = true
		if not await wait(0.55):
			return
		thinking = false
		if not over:
			put(ai())

func put(i: int) -> bool:
	if over or cells[i] != "":
		return false
	var m = "X" if turn == 0 else "O"
	cells[i] = m
	var b = bs[i]
	b.text = m
	for k in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(k, col(turn))
	b.pivot_offset = b.size / 2
	b.scale = Vector2(0.4, 0.4)
	create_tween().tween_property(b, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sound.tone(500 + turn * 180, 0.12, 2)
	var w = winner(cells)
	if w != "":
		for l in L:
			if cells[l[0]] == w and cells[l[1]] == w and cells[l[2]] == w:
				for k in 9:
					bs[k].modulate = Color.GOLD if l.has(k) else Color(0.6, 0.6, 0.6)
		finish("🏆 فاز " + m)
		return true
	if not cells.has(""):
		for k in 9:
			bs[k].modulate = Color(0.75, 0.75, 0.75)
		finish("🤝 تعادل", Color.WHITE)
		return true
	next_turn()
	return true

func winner(c: Array) -> String:
	for l in L:
		if c[l[0]] != "" and c[l[0]] == c[l[1]] and c[l[1]] == c[l[2]]:
			return c[l[0]]
	return ""

func minimax(c: Array, o_turn: bool, depth: int) -> int:
	var w = winner(c)
	if w == "O":
		return 10 - depth
	if w == "X":
		return depth - 10
	if not c.has(""):
		return 0
	var best = -100 if o_turn else 100
	for i in 9:
		if c[i] == "":
			c[i] = "O" if o_turn else "X"
			var v = minimax(c, not o_turn, depth + 1)
			c[i] = ""
			best = maxi(best, v) if o_turn else mini(best, v)
	return best

func ai() -> int:
	var free = []
	for i in 9:
		if cells[i] == "":
			free.append(i)
	if randf() < 0.18:
		return free.pick_random()
	var best_v = -100
	var best_i = []
	for i in free:
		cells[i] = "O"
		var v = minimax(cells, false, 1)
		cells[i] = ""
		if v > best_v:
			best_v = v
			best_i = [i]
		elif v == best_v:
			best_i.append(i)
	return best_i.pick_random()
