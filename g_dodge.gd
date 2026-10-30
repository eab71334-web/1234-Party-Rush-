extends "res://race.gd"
var obs = []
var spawn_t = 0.0
var px = 360.0
var acc = 0.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)

func hint_text() -> String:
	return Games.L("حرّك إصبعك وتفادى الكرات", "Drag to dodge the balls")

func inp(e: InputEvent) -> void:
	if e is InputEventMouseMotion or (e is InputEventMouseButton and e.pressed):
		px = clampf(e.position.x, 40.0, area.size.x - 40.0)

func tick(d: float) -> void:
	acc += d
	while acc >= 0.1:
		acc -= 0.1
		add(1)
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = maxf(0.25, 0.7 - (DURATION - time_left) * 0.012)
		obs.append([rng.randf_range(40.0, area.size.x - 40.0), -40.0, rng.randf_range(25.0, 50.0), rng.randf_range(300.0, 520.0)])
	var py = area.size.y - 120.0
	var keep = []
	for o in obs:
		o[1] += o[3] * d
		if Vector2(o[0], o[1]).distance_to(Vector2(px, py)) < o[2] + 28.0:
			Sound.lose()
			end_round()
			return
		if o[1] < area.size.y + 60.0:
			keep.append(o)
	obs = keep
	area.queue_redraw()

func paint() -> void:
	for o in obs:
		area.draw_circle(Vector2(o[0], o[1]), o[2], Color("ff4757"))
		area.draw_circle(Vector2(o[0] - o[2] * 0.3, o[1] - o[2] * 0.3), o[2] * 0.25, Color(1, 1, 1, 0.4))
	var py = area.size.y - 120.0
	area.draw_circle(Vector2(px, py), 28.0, Color("2ed573"))
	area.draw_circle(Vector2(px, py), 12.0, Color.WHITE)
