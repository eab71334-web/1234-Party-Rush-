extends "res://race.gd"
var pumps = 0
var limit = 10
var banked_btn: Button

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

func do_pump() -> void:
	if not running:
		return
	pumps += 1
	Sound.tone(300 + pumps * 25, 0.05, 2)
	if pumps >= limit:
		Sound.lose()
		pumps = 0
		limit = rng.randi_range(6, 30)
	area.queue_redraw()

func bank() -> void:
	if not running or pumps == 0:
		return
	add(pumps)
	Sound.tone(900, 0.12, 2)
	pumps = 0
	limit = rng.randi_range(6, 30)
	area.queue_redraw()

func paint() -> void:
	var c = Vector2(area.size.x / 2.0, area.size.y * 0.4)
	var r = 60.0 + pumps * 9.0
	area.draw_circle(c, r, Color("ff6b9d"))
	area.draw_circle(c + Vector2(-r * 0.3, -r * 0.3), r * 0.2, Color(1, 1, 1, 0.4))
	area.draw_line(c + Vector2(0, r), c + Vector2(10, r + 80), Color(1, 1, 1, 0.7), 4.0)
	area.draw_string(ThemeDB.fallback_font, Vector2(c.x - 200, c.y + 20), "+%d" % pumps, HORIZONTAL_ALIGNMENT_CENTER, 400, 60, Color.WHITE)
