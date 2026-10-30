extends "res://race.gd"
var y = 400.0
var vy = 0.0
var pipes = []
var spawn_t = 0.0
const PX = 200.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)

func hint_text() -> String:
	return Games.L("اضغط لترتفع وتعدّي الفتحات", "Tap to fly through the gaps")

func begin() -> void:
	y = area.size.y / 2.0

func inp(e: InputEvent) -> void:
	if running and e is InputEventMouseButton and e.pressed:
		vy = -620.0
		Sound.tone(600, 0.04, 2, -10.0)

func tick(d: float) -> void:
	vy += 1500.0 * d
	y += vy * d
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = 1.5
		pipes.append([area.size.x + 60.0, rng.randf_range(250.0, area.size.y - 250.0), false])
	var keep = []
	for p in pipes:
		p[0] -= 280.0 * d
		if absf(p[0] - PX) < 55.0 and absf(y - p[1]) > 120.0:
			Sound.lose()
			end_round()
			return
		if not p[2] and p[0] < PX - 55.0:
			p[2] = true
			add(1)
			Sound.tone(900, 0.06, 2)
		if p[0] > -80.0:
			keep.append(p)
	pipes = keep
	if y < 0.0 or y > area.size.y:
		Sound.lose()
		end_round()
		return
	area.queue_redraw()

func paint() -> void:
	for p in pipes:
		area.draw_style_box(Games.flat(Color("26de81"), 14), Rect2(p[0] - 50, 0, 100, p[1] - 120))
		area.draw_style_box(Games.flat(Color("26de81"), 14), Rect2(p[0] - 50, p[1] + 120, 100, area.size.y))
	Games.glyph(area, 12, Vector2(PX, y), 36.0, Color("ff6b6b"))
