extends "res://race.gd"
var items = []
var spawn_t = 0.0
var bx = 360.0
var cooldown = 0.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)

func hint_text() -> String:
	return Games.L("حرّك السلة والتقط النجوم وتجنب القنابل", "Drag the basket: catch stars, avoid bombs")

func inp(e: InputEvent) -> void:
	if e is InputEventMouseMotion or (e is InputEventMouseButton and e.pressed):
		bx = clampf(e.position.x, 70.0, area.size.x - 70.0)

func tick(d: float) -> void:
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = 0.45
		items.append([rng.randf_range(60.0, area.size.x - 60.0), -30.0, rng.randf() < 0.25, rng.randf_range(300.0, 480.0)])
	var by = area.size.y - 90.0
	for it in items:
		it[1] += it[3] * d
	var keep = []
	for it in items:
		if absf(it[1] - by) < 40.0 and absf(it[0] - bx) < 80.0:
			if it[2]:
				add(-3)
				Sound.tone(150, 0.2, 1)
			else:
				add(1)
				Sound.tone(900, 0.06, 2)
		elif it[1] < area.size.y + 40.0:
			keep.append(it)
	items = keep
	area.queue_redraw()

func paint() -> void:
	for it in items:
		if it[2]:
			Games.glyph(area, 14, Vector2(it[0], it[1]), 30.0, Color.WHITE)
		else:
			Games.glyph(area, 0, Vector2(it[0], it[1]), 32.0, Color("ffd32a"))
	var by = area.size.y - 90.0
	area.draw_style_box(Games.flat(Color("e17055"), 22), Rect2(bx - 70, by, 140, 60))
