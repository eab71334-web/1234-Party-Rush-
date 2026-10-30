extends "res://race.gd"
var pos_m = 0.0
var dirn = 1.0
var spd = 1.1
var zone = 0.5
var zw = 0.18

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)
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
	area.queue_redraw()

func inp(e: InputEvent) -> void:
	if not running or not (e is InputEventMouseButton and e.pressed):
		return
	var dist = absf(pos_m - zone)
	if dist < zw * 0.2:
		add(5)
		Sound.tone(1100, 0.1, 2)
	elif dist < zw * 0.5:
		add(3)
		Sound.tone(800, 0.08, 2)
	elif dist < zw:
		add(1)
		Sound.tone(600, 0.06, 2)
	else:
		add(-1)
		Sound.tone(180, 0.1, 1)
	zone = rng.randf_range(0.15, 0.85)
	zw = maxf(0.07, zw - 0.006)
	spd += 0.04

func paint() -> void:
	var w = area.size.x - 80.0
	var y = area.size.y * 0.45
	area.draw_style_box(Games.flat(Color(1, 1, 1, 0.15), 30), Rect2(40, y - 40, w, 80))
	area.draw_style_box(Games.flat(Color("2ed573"), 30), Rect2(40 + (zone - zw) * w, y - 40, zw * 2.0 * w, 80))
	area.draw_style_box(Games.flat(Color("ffd32a"), 12), Rect2(40 + pos_m * w - 12, y - 70, 24, 140))
