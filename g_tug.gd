extends "res://base.gd"
var p = 0.5
var pan = []
var lab = []
var tops = []
var lows = []
var top_box: HBoxContainer
var low_box: HBoxContainer
var seats = 2
var bot_seat = -1
var bot_t2 = 0.0

func team_top(s: int) -> bool:
	return s % 2 == 1

func build() -> void:
	seats = 2 if players == 1 else players
	if players == 1:
		bot_seat = 1
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 10)
	body.add_child(v)
	top_box = HBoxContainer.new()
	top_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_box.add_theme_constant_override("separation", 10)
	low_box = HBoxContainer.new()
	low_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	low_box.add_theme_constant_override("separation", 10)
	v.add_child(top_box)
	v.add_child(low_box)
	for s in seats:
		var top = team_top(s)
		var z = make_zone(s, top)
		z[1].text = Games.L("اضغط!", "TAP!")
		z[1].add_theme_font_size_override("font_size", 70)
		(top_box if top else low_box).add_child(z[0])
		pan.append(z[0])
		lab.append(z[1])
		if top:
			tops.append(s)
		else:
			lows.append(s)
	say(Games.L("شدّ الحبل! لكل لاعب مساحته", "Tug of war! Each player has a zone"), Color.WHITE)

func _input(e: InputEvent) -> void:
	if over:
		return
	for pt in presses(e):
		for s in seats:
			if s != bot_seat and pan[s].get_global_rect().has_point(pt):
				pull(s)

func _process(d: float) -> void:
	super._process(d)
	if over or bot_seat < 0:
		return
	bot_t2 += d
	if bot_t2 >= 0.22:
		bot_t2 = 0.0
		pull(bot_seat)

func pull(s: int) -> void:
	if over:
		return
	var top = team_top(s)
	var n = tops.size() if top else lows.size()
	var power = 0.04 / maxf(n, 1)
	p += power if top else -power
	Sound.tone(300 + (150 if top else 0), 0.04, 2, -12.0)
	pulse(lab[s])
	top_box.size_flags_stretch_ratio = maxf(p, 0.02)
	low_box.size_flags_stretch_ratio = maxf(1.0 - p, 0.02)
	if p >= 0.94:
		finish(Games.L("فاز الفريق العلوي", "Top team wins"), col(tops[0]))
	elif p <= 0.06:
		finish(Games.L("فاز الفريق السفلي", "Bottom team wins"), col(lows[0]))

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

func pulse(l: Control) -> void:
	l.pivot_offset = l.size / 2.0
	l.scale = Vector2(1.35, 1.35)
	create_tween().tween_property(l, "scale", Vector2.ONE, 0.18)
