extends "res://race.gd"
var pos_m = 0.0
var dirn = 1.0
var spd = 1.1
var zone = 0.5
var zw = 0.18
var feed_t = 0.0
var feed_text = ""
var feed_col = Color.WHITE

func setup() -> void:
	area.draw.connect(paint)
	zone = rng.randf_range(0.2, 0.8)

func hint_text() -> String:
	return Games.L("اضغط لما المؤشر يكون داخل الأخضر", "Tap when the marker is in the green")

func tick(d: float) -> void:
	pos_m += dirn * spd * d
	if pos_m > 1.0:
		pos_m = 1.0
		dirn = -1.0
	if pos_m < 0.0:
		pos_m = 0.0
		dirn = 1.0
	feed_t = maxf(0.0, feed_t - d * 1.6)
	area.queue_redraw()

func on_tap(_p: Vector2) -> void:
	var dist = absf(pos_m - zone)
	if dist < zw * 0.2:
		add(5)
		Sound.tone(1100, 0.1, 2)
		feed_text = "PERFECT +5"
		feed_col = Color("ffd32a")
	elif dist < zw * 0.5:
		add(3)
		Sound.tone(800, 0.08, 2)
		feed_text = "GREAT +3"
		feed_col = Color("2ed573")
	elif dist < zw:
		add(1)
		Sound.tone(600, 0.06, 2)
		feed_text = "OK +1"
		feed_col = Color("b8ffd9")
	else:
		add(-1)
		Sound.tone(180, 0.1, 1)
		feed_text = "MISS -1"
		feed_col = Color("ff4757")
	feed_t = 1.0
	zone = rng.randf_range(0.15, 0.85)
	zw = maxf(0.07, zw - 0.006)
	spd += 0.04

func paint() -> void:
	var w = area.size.x - 80.0
	var y = area.size.y * 0.45
	area.draw_style_box(Games.flat(Color(1, 1, 1, 0.15), 30), Rect2(40, y - 40, w, 80))
	area.draw_style_box(Games.flat(Color("1e9e55"), 30), Rect2(40 + (zone - zw) * w, y - 40, zw * 2.0 * w, 80))
	area.draw_style_box(Games.flat(Color("2ed573"), 24), Rect2(40 + (zone - zw * 0.5) * w, y - 40, zw * w, 80))
	area.draw_style_box(Games.flat(Color("b8ffd9"), 18), Rect2(40 + (zone - zw * 0.2) * w, y - 40, zw * 0.4 * w, 80))
	area.draw_style_box(Games.flat(Color("ffd32a"), 12), Rect2(40 + pos_m * w - 12, y - 70, 24, 140))
	if feed_t > 0.0:
		area.draw_string(ThemeDB.fallback_font, Vector2(0, y - 110.0 - (1.0 - feed_t) * 30.0), feed_text, HORIZONTAL_ALIGNMENT_CENTER, area.size.x, 54, Color(feed_col.r, feed_col.g, feed_col.b, feed_t))
