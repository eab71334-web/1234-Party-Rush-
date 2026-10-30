extends "res://base.gd"
const L = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
var cells = []
var bs = []

func build() -> void:
	var g = center_grid(3, 16)
	for i in 9:
		cells.append("")
		var b = Games.btn("", Color("3a2a7a"), 200, 110)
		b.custom_minimum_size = Vector2(200, 200)
		b.pressed.connect(play.bind(i))
		g.add_child(b)
		bs.append(b)
	show_turn()

func play(i: int) -> void:
	if over or cells[i] != "" or not my_turn():
		return
	if players == 1 and turn == 1:
		return
	act({"i": i})

func on_action(_seat: int, d: Dictionary) -> void:
	put(int(d.get("i", 0)))
	if players == 1 and not online and not over:
		if not await wait(0.5):
			return
		if not over:
			put(ai())

func put(i: int) -> void:
	if over or cells[i] != "":
		return
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
	for l in L:
		if cells[l[0]] != "" and cells[l[0]] == cells[l[1]] and cells[l[1]] == cells[l[2]]:
			for k in l:
				bs[k].modulate = Color.GOLD
			finish("🏆 فاز " + m)
			return
	if not cells.has(""):
		finish("🤝 تعادل", Color.WHITE)
		return
	next_turn()

func ai() -> int:
	for me in ["O", "X"]:
		for l in L:
			var line = [cells[l[0]], cells[l[1]], cells[l[2]]]
			if line.count(me) == 2 and line.count("") == 1:
				return l[line.find("")]
	if cells[4] == "":
		return 4
	var free = []
	for i in 9:
		if cells[i] == "":
			free.append(i)
	return free.pick_random()
