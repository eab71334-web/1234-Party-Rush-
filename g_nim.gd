extends "res://base.gd"
var sticks = 21

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
	show_turn()

func take(n: int) -> void:
	if over or not my_turn() or n > sticks:
		return
	act({"n": n})

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	var n = clampi(int(d.get("n", 1)), 1, mini(3, sticks))
	sticks -= n
	Sound.tone(300 + sticks * 15, 0.08, 2)
	body.queue_redraw()
	if sticks <= 0:
		finish(Games.L("خسر ", "") + Games.PN[seat] + Games.L(" (أخذ آخر عود)", " loses (took the last stick)"), Color("ff7675"))
	else:
		next_turn()

func paint() -> void:
	var W = body.size.x
	var per = 7
	var rows = 3
	var sw = minf(60.0, (W - 60.0) / per - 10.0)
	for i in sticks:
		var r = i / per
		var c = i % per
		var x = (W - per * (sw + 10.0)) / 2.0 + c * (sw + 10.0)
		var y = 30.0 + r * 200.0
		body.draw_style_box(Games.flat(Color("c8a27a").lightened(0.1 * (i % 2)), int(sw * 0.4)), Rect2(x, y, sw, 170))
		body.draw_circle(Vector2(x + sw / 2.0, y + 14.0), sw * 0.3, Color("8d6e63"))
