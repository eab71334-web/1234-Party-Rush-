extends "res://race.gd"
var items = []
var spawn_t = 0.0
var bursts = []
var flash = 0.0
const LIFE = 1.4

func setup() -> void:
	area.draw.connect(paint)

func hint_text() -> String:
	return Games.L("اضغط الأخضر فقط!", "Tap GREEN only!")

func item_radius(it: Array) -> float:
	var grow = clampf(it[2] / 0.12, 0.0, 1.0)
	var fade = 1.0 if it[2] < LIFE - 0.3 else maxf(0.0, (LIFE - it[2]) / 0.3)
	return 56.0 * grow * fade

func tick(d: float) -> void:
	flash = maxf(0.0, flash - d * 3.0)
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = maxf(0.32, 0.45 - (DURATION - time_left) * 0.003)
		items.append([Vector2(rng.randf_range(80.0, area.size.x - 80.0), rng.randf_range(80.0, area.size.y - 80.0)), rng.randf() < 0.6, 0.0])
	for it in items:
		it[2] += d
	items = items.filter(func(it): return it[2] < LIFE)
	for p in bursts:
		p[0] += p[1] * d
		p[2] += d
	bursts = bursts.filter(func(p): return p[2] < 0.35)
	area.queue_redraw()

func on_tap(pos: Vector2) -> void:
	for i in range(items.size() - 1, -1, -1):
		var it = items[i]
		if it[0].distance_to(pos) < 70.0:
			var c = Color("2ed573") if it[1] else Color("ff4757")
			for k in 8:
				var a = randf() * TAU
				bursts.append([it[0], Vector2(cos(a), sin(a)) * randf_range(100.0, 240.0), 0.0, c])
			if it[1]:
				add(1)
				Sound.tone(850, 0.05, 2)
			else:
				add(-2)
				flash = 1.0
				Sound.tone(160, 0.15, 1)
			items.remove_at(i)
			return

func paint() -> void:
	for it in items:
		var r = item_radius(it)
		if r < 1.0:
			continue
		var c = Color("2ed573") if it[1] else Color("ff4757")
		area.draw_circle(it[0], r, c)
		area.draw_circle(it[0] + Vector2(-16, -16) * (r / 56.0), 12.0 * (r / 56.0), Color(1, 1, 1, 0.4))
		area.draw_arc(it[0], r + 8.0, -PI / 2.0, -PI / 2.0 + TAU * (1.0 - it[2] / LIFE), 24, Color(1, 1, 1, 0.6), 4.0)
		var s = r * 0.35
		if it[1]:
			area.draw_polyline(PackedVector2Array([it[0] + Vector2(-s, 0), it[0] + Vector2(-s * 0.3, s * 0.7), it[0] + Vector2(s, -s * 0.7)]), Color.WHITE, 6.0)
		else:
			area.draw_line(it[0] + Vector2(-s, -s), it[0] + Vector2(s, s), Color.WHITE, 6.0)
			area.draw_line(it[0] + Vector2(s, -s), it[0] + Vector2(-s, s), Color.WHITE, 6.0)
	for p in bursts:
		var a2 = 1.0 - p[2] / 0.35
		area.draw_circle(p[0], 6.0 * a2 + 1.0, Color(p[3].r, p[3].g, p[3].b, a2))
	if flash > 0.0:
		area.draw_rect(Rect2(Vector2.ZERO, area.size), Color(1, 0.2, 0.2, 0.22 * flash))
