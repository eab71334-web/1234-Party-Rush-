extends "res://race.gd"
var items = []
var spawn_t = 0.0
var bx = 360.0
var tx = 360.0
var parts = []
var flash = 0.0
var tt = 0.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)

func hint_text() -> String:
	return Games.L("حرّك السلة والتقط النجوم وتجنب القنابل", "Drag the basket: catch stars, avoid bombs")

func begin() -> void:
	bx = area.size.x / 2.0
	tx = bx

func inp(e: InputEvent) -> void:
	if e is InputEventMouseMotion or (e is InputEventMouseButton and e.pressed):
		tx = clampf(e.position.x, 70.0, area.size.x - 70.0)

func burst(pos: Vector2, c: Color) -> void:
	for i in 8:
		var a = randf() * TAU
		parts.append([pos, Vector2(cos(a), sin(a)) * randf_range(80.0, 220.0), 0.0, c])

func catch_item(it: Array) -> void:
	var pos = Vector2(it[0], it[1])
	if it[2] == 1:
		add(-3)
		flash = 1.0
		burst(pos, Color("ff6b6b"))
		Sound.tone(150, 0.2, 1)
	elif it[2] == 2:
		add(3)
		burst(pos, Color("ffd32a"))
		Sound.tone(1100, 0.08, 2)
	else:
		add(1)
		burst(pos, Color("fff3a0"))
		Sound.tone(900, 0.06, 2)

func tick(d: float) -> void:
	tt += d
	flash = maxf(0.0, flash - d * 3.0)
	bx = lerpf(bx, tx, 1.0 - exp(-d * 20.0))
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = maxf(0.3, 0.45 - (DURATION - time_left) * 0.002)
		var r = rng.randf()
		var t = 1 if r < 0.22 else (2 if r < 0.28 else 0)
		items.append([rng.randf_range(60.0, area.size.x - 60.0), -30.0, t, rng.randf_range(300.0, 480.0)])
	var by = area.size.y - 90.0
	for it in items:
		it[1] += it[3] * d
	var keep = []
	for it in items:
		if absf(it[1] - by) < 40.0 and absf(it[0] - bx) < 80.0:
			catch_item(it)
		elif it[1] < area.size.y + 40.0:
			keep.append(it)
	items = keep
	for p in parts:
		p[0] += p[1] * d
		p[2] += d
	parts = parts.filter(func(p): return p[2] < 0.4)
	area.queue_redraw()

func paint() -> void:
	for it in items:
		var pos = Vector2(it[0], it[1])
		if it[2] == 1:
			Games.glyph(area, 14, pos, 30.0, Color.WHITE)
		elif it[2] == 2:
			area.draw_circle(pos, 40.0, Color(1, 0.85, 0.2, 0.2))
			Games.glyph(area, 0, pos, 38.0 + sin(tt * 8.0) * 3.0, Color("ffb800"))
		else:
			Games.glyph(area, 0, pos, 32.0, Color("ffd32a"))
	for p in parts:
		var a = 1.0 - p[2] / 0.4
		area.draw_circle(p[0], 6.0 * a + 1.0, Color(p[3].r, p[3].g, p[3].b, a))
	var by = area.size.y - 90.0
	var basket = PackedVector2Array([Vector2(bx - 70, by), Vector2(bx + 70, by), Vector2(bx + 52, by + 60), Vector2(bx - 52, by + 60)])
	area.draw_colored_polygon(basket, Color("e17055"))
	area.draw_style_box(Games.flat(Color("fab1a0"), 7), Rect2(bx - 76, by - 6, 152, 14))
	if flash > 0.0:
		area.draw_rect(Rect2(Vector2.ZERO, area.size), Color(1, 0.2, 0.2, 0.25 * flash))
