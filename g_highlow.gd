extends "res://base.gd"
var cur = [0, 7]
var prev = null
var scores = []
var count = 0
var last_ok = true
var total = 10
var anim = 1.0

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

func _process(d: float) -> void:
	super._process(d)
	if anim < 1.0:
		anim = minf(1.0, anim + d / 0.35)
		body.queue_redraw()

func guess(g: int) -> void:
	if over or not my_turn() or anim < 1.0:
		return
	act({"g": g})

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	var g = int(d.get("g", 0))
	var nw = [rng.randi() % 4, rng.randi_range(1, 13)]
	while nw[1] == cur[1]:
		nw = [rng.randi() % 4, rng.randi_range(1, 13)]
	last_ok = (nw[1] > cur[1]) if g == 0 else (nw[1] < cur[1])
	prev = cur
	cur = nw
	anim = 0.0
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
	var cy = 240.0
	var pw = (W - 40.0) / players
	for i in players:
		var rc = Rect2(20.0 + i * pw + 4.0, 10.0, pw - 8.0, 64.0)
		body.draw_style_box(Games.style(col(i) if i == turn else col(i).darkened(0.6), 24, 5), rc)
		body.draw_string(f, Vector2(rc.position.x, rc.position.y + 42.0), "%s  %d" % [Games.PN[i], scores[i]], HORIZONTAL_ALIGNMENT_CENTER, rc.size.x, 28, Color.WHITE)
	if prev != null:
		Games.pcard(body, Rect2(W * 0.5 - cw - 30, cy, cw, ch), prev[1], prev[0], true, true)
		var gc = Color(0.18, 0.84, 0.45, 0.35) if last_ok else Color(1, 0.28, 0.34, 0.35)
		body.draw_style_box(Games.flat(gc, 30), Rect2(W * 0.5 + 30 - 14, cy - 14, cw + 28, ch + 28))
	var e = 1.0 - pow(1.0 - anim, 3.0)
	var s = 0.6 + 0.4 * e
	var ctr = Vector2(W * 0.5 + 30 + cw / 2.0, cy + ch / 2.0)
	body.draw_set_transform(ctr, 0.0, Vector2(s, s))
	Games.pcard(body, Rect2(-cw / 2.0, -ch / 2.0, cw, ch), cur[1], cur[0], true)
	body.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var ph = int(round((13 - cur[1]) / 12.0 * 100.0))
	var pl = int(round((cur[1] - 1) / 12.0 * 100.0))
	body.draw_string(f, Vector2(0, cy + ch + 70.0), Games.L("أعلى %d%%   |   أقل %d%%" % [ph, pl], "Higher %d%%   |   Lower %d%%" % [ph, pl]), HORIZONTAL_ALIGNMENT_CENTER, W, 32, Color(1, 1, 1, 0.8))
	if prev != null:
		body.draw_string(f, Vector2(0, cy - 40.0), Games.L("صح!", "Correct!") if last_ok else Games.L("غلط", "Wrong"), HORIZONTAL_ALIGNMENT_CENTER, W, 44, Color("2ed573") if last_ok else Color("ff4757"))
