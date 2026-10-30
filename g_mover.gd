extends "res://race.gd"
var p = Vector2(360, 400)
var v = Vector2(300, 220)
var r = 70.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)
	v = Vector2(rng.randf_range(250.0, 400.0), rng.randf_range(200.0, 350.0))

func hint_text() -> String:
	return Games.L("اضغط الدائرة المتحركة", "Tap the moving circle")

func tick(d: float) -> void:
	p += v * d
	if p.x < r or p.x > area.size.x - r:
		v.x = -v.x
		p.x = clampf(p.x, r, area.size.x - r)
	if p.y < r or p.y > area.size.y - r:
		v.y = -v.y
		p.y = clampf(p.y, r, area.size.y - r)
	area.queue_redraw()

func inp(e: InputEvent) -> void:
	if running and e is InputEventMouseButton and e.pressed:
		if e.position.distance_to(p) < r + 15.0:
			add(1)
			Sound.tone(800, 0.05, 2)
			v = v * 1.06
			v = v.rotated(randf_range(-1.0, 1.0))
			r = maxf(38.0, r - 1.5)
		else:
			add(-1)

func paint() -> void:
	area.draw_circle(p, r, Color("1dd1a1"))
	area.draw_circle(p, r * 0.55, Color("10ac84"))
	area.draw_circle(p, r * 0.2, Color.WHITE)
