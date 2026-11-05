extends "res://base.gd"
var sticks = 21
var gone = []
var btns = []

func build() -> void:
	canvas(paint, noop)
	var hb = HBoxContainer.new()
	hb.set_anchors_preset(PRESET_BOTTOM_WIDE)
	hb.offset_top = -170
	hb.offset_bottom = -10
	hb.offset_left = 20
	hb.offset_right = -20
	hb.add_theme_constant_override("separation", 16)
	body.add_child(hb)
	for n in [1, 2, 3]:
		var b = Games.btn(Games.L("خذ ", "Take ") + str(n), Games.PC[n], 150, 50)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.button_down.connect(take.bind(n))
		hb.add_child(b)
		btns.append(b)
	show_turn()
	refresh_btns()

func refresh_btns() -> void:
	for k in btns.size():
		btns[k].disabled = over or (k + 1) > sticks or not my_turn()

func _process(d: float) -> void:
	super._process(d)
	if gone.is_empty():
		return
	for g in gone:
		g[1] += d
	gone = gone.filter(func(g): return g[1] < 0.45)
	body.queue_redraw()

func take(n: int) -> void:
	if over or not my_turn() or n > sticks:
		return
	act({"n": n})

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	var n = clampi(int(d.get("n", 1)), 1, mini(3, sticks))
	for k in range(sticks - n, sticks):
		gone.append([k, 0.0])
	sticks -= n
	Sound.tone(300 + sticks * 15, 0.08, 2)
	body.queue_redraw()
	if sticks <= 0:
		finish(Games.L("خسر ", "") + Games.PN[seat] + Games.L(" (أخذ آخر عود)", " loses (took the last stick)"), Color("ff7675"))
	else:
		next_turn()
	refresh_btns()

func stick_pos(i: int, W: float) -> Vector2:
	var per = 7
	var sw = minf(60.0, (W - 60.0) / per - 10.0)
	var r = i / per
	var c = i % per
	return Vector2((W - per * (sw + 10.0)) / 2.0 + c * (sw + 10.0), 30.0 + r * 200.0)

func paint() -> void:
	var W = body.size.x
	var per = 7
	var sw = minf(60.0, (W - 60.0) / per - 10.0)
	for i in sticks:
		var p = stick_pos(i, W)
		body.draw_style_box(Games.flat(Color("c8a27a").lightened(0.1 * (i % 2)), int(sw * 0.4)), Rect2(p.x, p.y, sw, 170))
		body.draw_circle(Vector2(p.x + sw / 2.0, p.y + 14.0), sw * 0.3, Color("8d6e63"))
	for g in gone:
		var k = g[1] / 0.45
		var p2 = stick_pos(g[0], W)
		var a = 1.0 - k
		body.draw_set_transform(Vector2(p2.x + sw / 2.0, p2.y + 85.0 + k * 120.0), k * 1.2, Vector2.ONE)
		body.draw_style_box(Games.flat(Color(0.78, 0.64, 0.48, a), int(sw * 0.4)), Rect2(-sw / 2.0, -85.0, sw, 170))
		body.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var f = ThemeDB.fallback_font
	body.draw_string(f, Vector2(0, 30.0 + 3 * 200.0 + 30.0), Games.L("المتبقي: %d" % sticks, "Left: %d" % sticks), HORIZONTAL_ALIGNMENT_CENTER, W, 44, Color.WHITE)
	body.draw_string(f, Vector2(0, 30.0 + 3 * 200.0 + 80.0), Games.L("من يأخذ آخر عود يخسر", "Taking the last stick loses"), HORIZONTAL_ALIGNMENT_CENTER, W, 28, Color(1, 1, 1, 0.7))
