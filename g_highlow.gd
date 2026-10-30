extends "res://base.gd"
var cur = [0, 7]
var prev = null
var scores = []
var count = 0
var last_ok = true
var total = 10

func build() -> void:
	total = players * 5
	for i in players:
		scores.append(0)
	cur = [rng.randi() % 4, rng.randi_range(1, 13)]
	canvas(paint, noop)
	var hb = HBoxContainer.new()
	hb.set_anchors_preset(PRESET_BOTTOM_WIDE)
	hb.offset_top = -170
	hb.offset_bottom = -10
	hb.offset_left = 20
	hb.offset_right = -20
	hb.add_theme_constant_override("separation", 16)
	body.add_child(hb)
	var hi = Games.btn(Games.L("أعلى", "Higher"), Color("27ae60"), 150, 52)
	hi.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hi.button_down.connect(guess.bind(0))
	hb.add_child(hi)
	var lo = Games.btn(Games.L("أقل", "Lower"), Color("c0392b"), 150, 52)
	lo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lo.button_down.connect(guess.bind(1))
	hb.add_child(lo)
	show_turn()

func guess(g: int) -> void:
	if over or not my_turn():
		return
	act({"g": g})

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	var g = int(d.get("g", 0))
	var nw = [rng.randi() % 4, rng.randi_range(1, 13)]
	last_ok = (nw[1] > cur[1]) if g == 0 else (nw[1] < cur[1])
	prev = cur
	cur = nw
	if last_ok:
		scores[seat] += 1
		Sound.tone(900, 0.12, 2)
	else:
		Sound.tone(180, 0.15, 1)
	count += 1
	body.queue_redraw()
	if count >= total:
		var best = 0
		for i in players:
			if scores[i] > scores[best]:
				best = i
		if scores.count(scores[best]) > 1:
			finish(Games.L("تعادل", "Draw"), Color.WHITE)
		else:
			finish("فاز " + Games.PN[best], col(best))
	else:
		next_turn()

func paint() -> void:
	var W = body.size.x
	var f = ThemeDB.fallback_font
	var cw = minf(220.0, W * 0.32)
	var ch = cw / 0.68
	if prev != null:
		Games.pcard(body, Rect2(W * 0.5 - cw - 30, 150, cw, ch), prev[1], prev[0], true, true)
	Games.pcard(body, Rect2(W * 0.5 + 30, 150, cw, ch), cur[1], cur[0], true)
	var s = ""
	for i in players:
		s += "%s: %d    " % [Games.PN[i], scores[i]]
	body.draw_string(f, Vector2(0, 60), s, HORIZONTAL_ALIGNMENT_CENTER, W, 38, Color.WHITE)
	if prev != null:
		body.draw_string(f, Vector2(0, 120), Games.L("صح!", "Correct!") if last_ok else Games.L("غلط", "Wrong"), HORIZONTAL_ALIGNMENT_CENTER, W, 44, Color("2ed573") if last_ok else Color("ff4757"))
