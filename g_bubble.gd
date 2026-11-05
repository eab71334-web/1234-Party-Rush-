extends "res://race.gd"
var bubbles = []
var spawn_t = 0.0
var bursts = []

func setup() -> void:
	area.draw.connect(paint)

func hint_text() -> String:
	return Games.L("فرقع الفقاعات (الصغيرة بنقطتين)", "Pop the bubbles (small = 2 pts)")

func cur_radius(b: Array) -> float:
	var k = 1.0 - b[2] / 2.0
	var grow = minf(1.0, b[2] / 0.15)
	return b[1] * (0.55 + 0.45 * k) * grow

func tick(d: float) -> void:
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = maxf(0.28, 0.5 - (DURATION - time_left) * 0.004)
		var w = area.size.x
		var h = area.size.y
		bubbles.append([Vector2(rng.randf_range(90.0, w - 90.0), rng.randf_range(90.0, h - 90.0)), rng.randf_range(45.0, 85.0), 0.0])
	for b in bubbles:
		b[2] += d
	bubbles = bubbles.filter(func(b): return b[2] < 2.0)
	for p in bursts:
		p[0] += p[1] * d
		p[2] += d
	bursts = bursts.filter(func(p): return p[2] < 0.35)
	area.queue_redraw()

func on_tap(p: Vector2) -> void:
	for i in range(bubbles.size() - 1, -1, -1):
		var b = bubbles[i]
		var r = cur_radius(b)
		if b[0].distance_to(p) < r + 12.0:
			for k in 8:
				var a = randf() * TAU
				bursts.append([b[0], Vector2(cos(a), sin(a)) * randf_range(100.0, 260.0), 0.0])
			bubbles.remove_at(i)
			add(2 if b[1] < 60.0 else 1)
			Sound.tone(700 + randi() % 300, 0.05, 2)
			return

func paint() -> void:
	for b in bubbles:
		var r = cur_radius(b)
		area.draw_circle(b[0], r, Color(0.3, 0.75, 1.0, 0.55))
		area.draw_arc(b[0], r, 0, TAU, 28, Color(1, 1, 1, 0.8), 4.0)
		area.draw_circle(b[0] + Vector2(-0.3, -0.3) * r, r * 0.2, Color(1, 1, 1, 0.7))
	for p in bursts:
		var a = 1.0 - p[2] / 0.35
		area.draw_circle(p[0], 7.0 * a + 1.0, Color(0.6, 0.9, 1.0, a))
