extends "res://race.gd"
var pumps = 0
var limit = 10
var shown_r = 60.0
var parts = []
var tt = 0.0
var flash = 0.0
var bank_t = 0.0
var bank_n = 0

func setup() -> void:
	area.draw.connect(paint)
	var hb = HBoxContainer.new()
	hb.set_anchors_preset(PRESET_BOTTOM_WIDE)
	hb.offset_top = -170
	hb.offset_bottom = -20
	hb.add_theme_constant_override("separation", 20)
	area.add_child(hb)
	var p = Games.btn(Games.L("انفخ", "PUMP"), Color("ff6b9d"), 150, 54)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.button_down.connect(do_pump)
	hb.add_child(p)
	var s = Games.btn(Games.L("احفظ", "BANK"), Color("2ed573"), 150, 54)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.button_down.connect(bank)
	hb.add_child(s)
	limit = rng.randi_range(6, 30)

func hint_text() -> String:
	return Games.L("انفخ واحفظ قبل ما ينفجر!", "Pump, but bank before it pops!")

func tick(d: float) -> void:
	tt += d
	shown_r = lerpf(shown_r, 60.0 + pumps * 9.0, 1.0 - exp(-d * 14.0))
	flash = maxf(0.0, flash - d * 3.0)
	bank_t = maxf(0.0, bank_t - d * 1.5)
	for p in parts:
		p[0] += p[1] * d
		p[1].y += 600.0 * d
		p[2] += d
	parts = parts.filter(func(p): return p[2] < 0.7)
	area.queue_redraw()

func center() -> Vector2:
	return Vector2(area.size.x / 2.0, area.size.y * 0.4)

func do_pump() -> void:
	if not running:
		return
	pumps += 1
	Sound.tone(300 + pumps * 25, 0.05, 2)
	if pumps >= limit:
		for i in 18:
			var a = randf() * TAU
			parts.append([center(), Vector2(cos(a), sin(a)) * randf_range(150.0, 450.0), 0.0])
		flash = 1.0
		Sound.lose()
		pumps = 0
		shown_r = 60.0
		limit = rng.randi_range(6, 30)

func bank() -> void:
	if not running or pumps == 0:
		return
	add(pumps)
	bank_n = pumps
	bank_t = 1.0
	Sound.tone(900, 0.12, 2)
	pumps = 0
	limit = rng.randi_range(6, 30)

func paint() -> void:
	var shake = Vector2(sin(tt * 40.0), cos(tt * 37.0)) * pumps * 0.25
	var c = center() + Vector2(0, sin(tt * 3.0) * 4.0) + shake
	var r = shown_r
	var bc = Color("ff6b9d").lerp(Color("ff2f55"), clampf(pumps / 30.0, 0.0, 1.0))
	area.draw_line(c + Vector2(0, r), c + Vector2(10 + sin(tt * 2.0) * 8.0, r + 80), Color(1, 1, 1, 0.7), 4.0)
	area.draw_circle(c, r, bc)
	area.draw_colored_polygon(PackedVector2Array([c + Vector2(0, r + 8), c + Vector2(-12, r + 24), c + Vector2(12, r + 24)]), bc.darkened(0.2))
	area.draw_circle(c + Vector2(-r * 0.3, -r * 0.3), r * 0.2, Color(1, 1, 1, 0.4))
	var f = ThemeDB.fallback_font
	area.draw_string(f, Vector2(c.x - 200, c.y + 20), "+%d" % pumps, HORIZONTAL_ALIGNMENT_CENTER, 400, 60, Color.WHITE)
	for p in parts:
		var a = 1.0 - p[2] / 0.7
		area.draw_circle(p[0], 9.0 * a + 1.0, Color(1.0, 0.42, 0.62, a))
	if bank_t > 0.0:
		area.draw_string(f, Vector2(0, area.size.y * 0.2 - (1.0 - bank_t) * 40.0), "+%d" % bank_n, HORIZONTAL_ALIGNMENT_CENTER, area.size.x, 72, Color(0.18, 0.84, 0.45, bank_t))
	if flash > 0.0:
		area.draw_rect(Rect2(Vector2.ZERO, area.size), Color(1, 0.2, 0.3, 0.25 * flash))
