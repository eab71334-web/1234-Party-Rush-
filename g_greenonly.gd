extends "res://race.gd"
var items = []
var spawn_t = 0.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)

func hint_text() -> String:
	return Games.L("اضغط الأخضر فقط!", "Tap GREEN only!")

func tick(d: float) -> void:
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = 0.45
		items.append([Vector2(rng.randf_range(80.0, area.size.x - 80.0), rng.randf_range(80.0, area.size.y - 80.0)), rng.randf() < 0.6, 0.0])
	for it in items:
		it[2] += d
	items = items.filter(func(it): return it[2] < 1.4)
	area.queue_redraw()

func inp(e: InputEvent) -> void:
	if running and e is InputEventMouseButton and e.pressed:
		for i in range(items.size() - 1, -1, -1):
			if items[i][0].distance_to(e.position) < 70.0:
				if items[i][1]:
					add(1)
					Sound.tone(850, 0.05, 2)
				else:
					add(-2)
					Sound.tone(160, 0.15, 1)
				items.remove_at(i)
				return

func paint() -> void:
	for it in items:
		var c = Color("2ed573") if it[1] else Color("ff4757")
		area.draw_circle(it[0], 56.0, c)
		area.draw_circle(it[0] + Vector2(-16, -16), 12.0, Color(1, 1, 1, 0.4))
