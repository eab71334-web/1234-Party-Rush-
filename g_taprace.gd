extends "res://base.gd"
const GOAL = 25
var score = []
var pan = []
var lab = []
var t0 = 0

func build() -> void:
	make_zones(players)
	for i in players:
		score.append(0)
		lab[i].text = "0"
	say(Games.L("اضغط مساحتك بسرعة! الهدف %d" % GOAL, "Tap your zone fast! Goal %d" % GOAL), Color.WHITE)

func _input(e: InputEvent) -> void:
	if over:
		return
	for pt in presses(e):
		for s in players:
			if pan[s] != null and pan[s].get_global_rect().has_point(pt):
				tap(s)

func tap(i: int) -> void:
	if over:
		return
	if t0 == 0:
		t0 = Time.get_ticks_msec()
	score[i] += 1
	lab[i].text = str(score[i])
	pulse(lab[i])
	Sound.tone(400 + score[i] * 15, 0.05, 2, -10.0)
	if score[i] >= GOAL:
		var secs = (Time.get_ticks_msec() - t0) / 1000.0
		if players == 1:
			finish(Games.L("خلصت في %.1f ثانية" % secs, "Finished in %.1f s" % secs))
		else:
			finish("فاز " + Games.PN[i], col(i))

func slots(n: int) -> Array:
	if n == 2:
		return [1, 0]
	if n == 3:
		return [2, -1, 0, 1]
	if n >= 4:
		return [2, 3, 0, 1]
	return [0]

func presses(e: InputEvent) -> Array:
	if e is InputEventScreenTouch and e.pressed:
		return [e.position]
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and not DisplayServer.is_touchscreen_available():
		return [e.position]
	return []

func make_zone(s: int, rotated: bool) -> Array:
	var p = Panel.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.size_flags_vertical = Control.SIZE_EXPAND_FILL
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", Games.style(col(s), 34, 10))
	var l = big_label("", 110, Color.WHITE)
	l.set_anchors_preset(PRESET_FULL_RECT)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if rotated:
		l.rotation = PI
		l.resized.connect(func(): l.pivot_offset = l.size / 2.0)
	p.add_child(l)
	return [p, l]

func paint_zone(p: Panel, c: Color) -> void:
	p.add_theme_stylebox_override("panel", Games.style(c, 34, 10))

func make_zones(n: int) -> void:
	var sl = slots(n)
	var g = GridContainer.new()
	g.columns = 1 if n <= 2 else 2
	g.set_anchors_preset(PRESET_FULL_RECT)
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 14)
	body.add_child(g)
	for k in n:
		pan.append(null)
		lab.append(null)
	for si in sl.size():
		var s = sl[si]
		if s < 0:
			var gap = Control.new()
			gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
			gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			g.add_child(gap)
			continue
		var z = make_zone(s, n > 1 and si < sl.size() / 2)
		g.add_child(z[0])
		pan[s] = z[0]
		lab[s] = z[1]

func pulse(l: Control) -> void:
	l.pivot_offset = l.size / 2.0
	l.scale = Vector2(1.35, 1.35)
	create_tween().tween_property(l, "scale", Vector2.ONE, 0.18)
