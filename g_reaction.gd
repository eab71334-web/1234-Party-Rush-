extends "res://base.gd"
const ROUNDS = 5
var pan = []
var lab = []
var sc = []
var phase = "idle"
var rnd = 0
var rid = 0
var t0 = 0

func build() -> void:
	make_zones(players)
	for i in players:
		sc.append(0)
	labels()
	start_round()

func labels() -> void:
	for i in players:
		lab[i].text = "%s\n%d" % [Games.PN[i], sc[i]]
		lab[i].add_theme_font_size_override("font_size", 56)

func tint_all(c: Color) -> void:
	for p in pan:
		if p != null:
			paint_zone(p, c)

func _input(e: InputEvent) -> void:
	if over:
		return
	for pt in presses(e):
		for s in players:
			if pan[s] != null and pan[s].get_global_rect().has_point(pt):
				tap(s)

func start_round() -> void:
	rid += 1
	var my = rid
	phase = "wait"
	tint_all(Color("636e72"))
	say(Games.L("انتظر اللون الأخضر...", "Wait for green..."), Color.WHITE)
	if not await wait(randf_range(1.5, 4.0)):
		return
	if phase != "wait" or my != rid:
		return
	phase = "go"
	tint_all(Color("00b894"))
	say(Games.L("اضغط الآن!!", "TAP NOW!!"), Color("00b894"))
	Sound.tone(880, 0.2, 2)
	t0 = Time.get_ticks_msec()

func tap(i: int) -> void:
	if over:
		return
	if phase == "wait":
		phase = "between"
		sc[i] -= 1
		paint_zone(pan[i], Color("d63031"))
		say("%s %s" % [Games.PN[i], Games.L("استعجل! -1", "too early! -1")], Color("ff7675"))
		Sound.lose()
		after_round()
	elif phase == "go":
		phase = "between"
		sc[i] += 1
		var ms = Time.get_ticks_msec() - t0
		paint_zone(pan[i], col(i))
		say("%s - %d ms" % [Games.PN[i], ms], col(i))
		Sound.tone(1000, 0.15, 2)
		pulse(lab[i])
		after_round()

func after_round() -> void:
	rnd += 1
	labels()
	if not await wait(1.4):
		return
	if rnd >= ROUNDS:
		var best = 0
		for i in players:
			if sc[i] > sc[best]:
				best = i
		if players == 1:
			finish(Games.L("نقاطك: %d من %d" % [sc[0], ROUNDS], "Your points: %d of %d" % [sc[0], ROUNDS]))
		elif sc.count(sc[best]) > 1:
			finish("تعادل", Color.WHITE)
		else:
			finish("فاز " + Games.PN[best], col(best))
	else:
		start_round()

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
