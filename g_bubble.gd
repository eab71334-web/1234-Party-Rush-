extends "res://race.gd"
var bubbles = []
var spawn_t = 0.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)

func hint_text() -> String:
	return Games.L("فرقع الفقاعات", "Pop the bubbles")

func tick(d: float) -> void:
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = 0.5
		var w = area.size.x
		var h = area.size.y
		bubbles.append([Vector2(rng.randf_range(90.0, w - 90.0), rng.randf_range(90.0, h - 90.0)), rng.randf_range(45.0, 85.0), 0.0])
	for b in bubbles:
		b[2] += d
	bubbles = bubbles.filter(func(b): return b[2] < 2.0)
	area.queue_redraw()

func inp(e: InputEvent) -> void:
	if running and e is InputEventMouseButton and e.pressed:
		for i in range(bubbles.size() - 1, -1, -1):
			if bubbles[i][0].distance_to(e.position) < bubbles[i][1]:
				bubbles.remove_at(i)
				add(1)
				Sound.tone(700 + randi() % 300, 0.05, 2)
				return

func paint() -> void:
	for b in bubbles:
		var k = 1.0 - b[2] / 2.0
		var r = b[1] * (0.55 + 0.45 * k)
		area.draw_circle(b[0], r, Color(0.3, 0.75, 1.0, 0.55))
		area.draw_arc(b[0], r, 0, TAU, 28, Color(1, 1, 1, 0.8), 4.0)
		area.draw_circle(b[0] + Vector2(-0.3, -0.3) * r, r * 0.2, Color(1, 1, 1, 0.7))
