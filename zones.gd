extends "res://base.gd"
# إطار مناطق اللمس: لكل لاعب منطقة خاصة به، وكل لمسة تُقرأ مستقلة (يدعم عدة أصابع بنفس اللحظة)
var pan = []
var lab = []
var ztw = {}
var ripples = []
var fx: Control

func _ready() -> void:
	super._ready()
	fx = Control.new()
	fx.set_anchors_preset(PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.draw.connect(draw_fx)
	add_child(fx)

func _process(d: float) -> void:
	super._process(d)
	if ripples.is_empty():
		return
	for r in ripples:
		r[1] += d
	ripples = ripples.filter(func(r): return r[1] < 0.45)
	fx.queue_redraw()

func draw_fx() -> void:
	for r in ripples:
		var k = r[1] / 0.45
		var c = r[2]
		var rad = 30.0 + 150.0 * k
		fx.draw_circle(r[0], rad, Color(c.r, c.g, c.b, 0.35 * (1.0 - k)))
		fx.draw_arc(r[0], rad, 0, TAU, 40, Color(1, 1, 1, 0.8 * (1.0 - k)), 5.0)

# ---------- اللمس ----------
func presses(e: InputEvent) -> Array:
	if e is InputEventScreenTouch and e.pressed:
		return [e.position]
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and not DisplayServer.is_touchscreen_available():
		return [e.position]
	return []

func zone_at(pt: Vector2) -> int:
	for s in pan.size():
		if pan[s] != null and pan[s].get_global_rect().has_point(pt):
			return s
	return -1

func _input(e: InputEvent) -> void:
	if over or not is_inside_tree():
		return
	for pt in presses(e):
		var s = zone_at(pt)
		if s >= 0:
			on_zone_press(s, pt)

func on_zone_press(_s: int, _pt: Vector2) -> void:
	pass

# ---------- التأثيرات ----------
func press_fx(s: int, pt: Vector2) -> void:
	if ripples.size() > 24:
		ripples.pop_front()
	ripples.append([pt, 0.0, col(s)])
	press_flash(s)

func press_flash(s: int) -> void:
	var p = pan[s]
	if p == null:
		return
	if ztw.has(s) and ztw[s].is_valid():
		ztw[s].kill()
	p.modulate = Color(1.3, 1.3, 1.3)
	var tw = create_tween()
	tw.tween_property(p, "modulate", Color.WHITE, 0.15)
	ztw[s] = tw

func pulse(l: Control) -> void:
	l.pivot_offset = l.size / 2.0
	l.scale = Vector2(1.35, 1.35)
	create_tween().tween_property(l, "scale", Vector2.ONE, 0.18)

func set_progress(s: int, f: float) -> void:
	var p = pan[s]
	if p == null:
		return
	var track = p.get_meta("track")
	var fill = p.get_meta("fill")
	track.visible = true
	f = clampf(f, 0.0, 1.0)
	var w = track.size.x * f
	fill.size = Vector2(w, track.size.y)
	fill.position = Vector2(track.size.x - w if p.get_meta("rot") else 0.0, 0.0)

func dim_others(winner: int) -> void:
	for s in pan.size():
		if s != winner and pan[s] != null:
			pan[s].modulate = Color(0.55, 0.55, 0.55)

# ---------- بناء المناطق ----------
func slots(n: int) -> Array:
	if n == 2:
		return [1, 0]
	if n == 3:
		return [2, -1, 0, 1]
	if n >= 4:
		return [2, 3, 0, 1]
	return [0]

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
	# شريط التقدم (مخفي حتى يُستخدم)
	var track = Panel.new()
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_theme_stylebox_override("panel", Games.flat(Color(0, 0, 0, 0.3), 8))
	track.anchor_left = 0.08
	track.anchor_right = 0.92
	if rotated:
		track.anchor_top = 0.0
		track.anchor_bottom = 0.0
		track.offset_top = 20.0
		track.offset_bottom = 36.0
	else:
		track.anchor_top = 1.0
		track.anchor_bottom = 1.0
		track.offset_top = -36.0
		track.offset_bottom = -20.0
	track.offset_left = 0.0
	track.offset_right = 0.0
	track.visible = false
	var fill = Panel.new()
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.add_theme_stylebox_override("panel", Games.flat(Color(1, 1, 1, 0.9), 8))
	track.add_child(fill)
	p.add_child(track)
	p.set_meta("track", track)
	p.set_meta("fill", fill)
	p.set_meta("rot", rotated)
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
