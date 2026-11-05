extends "res://race.gd"
var p = Vector2(360, 400)
var v = Vector2(300, 220)
var r = 70.0
var trail = []
var pulse = 0.0
var miss = 0.0

func setup() -> void:
	area.draw.connect(paint)
	v = Vector2(rng.randf_range(250.0, 400.0), rng.randf_range(200.0, 350.0))

func hint_text() -> String:
	return Games.L("اضغط الدائرة المتحركة", "Tap the moving circle")

func begin() -> void:
	p = area.size / 2.0

func tick(d: float) -> void:
	p += v * d
	if p.x < r or p.x > area.size.x - r:
		v.x = -v.x
		p.x = clampf(p.x, r, area.size.x - r)
	if p.y < r or p.y > area.size.y - r:
		v.y = -v.y
		p.y = clampf(p.y, r, area.size.y - r)
	trail.append(p)
	if trail.size() > 8:
		trail.pop_front()
	pulse = maxf(0.0, pulse - d * 5.0)
	miss = maxf(0.0, miss - d * 3.0)
	area.queue_redraw()

func on_tap(pos: Vector2) -> void:
	if pos.distance_to(p) < r + 15.0:
		add(1)
		Sound.tone(800, 0.05, 2)
		v = (v * 1.06).limit_length(900.0)
		v = v.rotated(rng.randf_range(-1.0, 1.0))
		if v.length() < 250.0:
			v = v.normalized() * 250.0
		r = maxf(38.0, r - 1.5)
		pulse = 1.0
	else:
		add(-1)
		miss = 1.0
		Sound.tone(150, 0.1, 1)

func paint() -> void:
	for i in trail.size():
		var a = float(i) / maxf(trail.size(), 1)
		area.draw_circle(trail[i], r * 0.8 * a, Color(0.11, 0.82, 0.63, 0.25 * a))
	var rr = r * (1.0 + pulse * 0.2)
	area.draw_circle(p, rr * 1.25, Color(0.11, 0.82, 0.63, 0.15))
	area.draw_circle(p, rr, Color("1dd1a1"))
	area.draw_circle(p, rr * 0.55, Color("10ac84"))
	area.draw_circle(p, rr * 0.2, Color.WHITE)
	if miss > 0.0:
		area.draw_rect(Rect2(Vector2.ZERO, area.size), Color(1, 0.2, 0.2, 0.18 * miss))
