extends "res://race.gd"
var bump = 0.0
var rip = []

func setup() -> void:
	time_left = 10.0
	area.draw.connect(paint)

func hint_text() -> String:
	return Games.L("اضغط أسرع ما تقدر!", "Tap as fast as you can!")

func _input(e: InputEvent) -> void:
	if not running:
		return
	var pt = null
	if e is InputEventScreenTouch and e.pressed:
		pt = e.position
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and not DisplayServer.is_touchscreen_available():
		pt = e.position
	if pt == null or not area.get_global_rect().has_point(pt):
		return
	add(1)
	bump = 1.0
	if rip.size() > 20:
		rip.pop_front()
	rip.append([pt - area.global_position, 0.0])
	Sound.tone(500 + (score % 20) * 20, 0.03, 2, -10.0)

func tick(d: float) -> void:
	bump = maxf(0.0, bump - d * 6.0)
	for r in rip:
		r[1] += d
	rip = rip.filter(func(r): return r[1] < 0.4)
	area.queue_redraw()

func paint() -> void:
	var c = col(my_seat if online else 0)
	var ctr = area.size / 2.0
	var r = minf(area.size.x, area.size.y) * 0.3 * (1.0 + bump * 0.12)
	var f = ThemeDB.fallback_font
	for q in rip:
		var k = q[1] / 0.4
		area.draw_arc(q[0], 30.0 + 160.0 * k, 0, TAU, 36, Color(1, 1, 1, 0.7 * (1.0 - k)), 5.0)
	area.draw_circle(ctr, r * 1.3, Color(c.r, c.g, c.b, 0.18))
	area.draw_circle(ctr, r, c)
	area.draw_arc(ctr, r, 0, TAU, 48, Color(1, 1, 1, 0.85), 8.0)
	area.draw_string(f, Vector2(ctr.x - 200.0, ctr.y + 30.0), "TAP!", HORIZONTAL_ALIGNMENT_CENTER, 400, 90, Color.WHITE)
	area.draw_string(f, Vector2(ctr.x - 200.0, ctr.y + r + 110.0), str(score), HORIZONTAL_ALIGNMENT_CENTER, 400, 110, Color(1, 1, 1, 0.9))
