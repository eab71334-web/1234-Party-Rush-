extends "res://race.gd"
var y = 400.0
var vy = 0.0
var pipes = []
var spawn_t = 0.0
var flame = []
var flame_t = 0.0
var tt = 0.0
const PX = 200.0

func setup() -> void:
	area.draw.connect(paint)

func hint_text() -> String:
	return Games.L("اضغط لترتفع وتعدّي الفتحات", "Tap to fly through the gaps")

func begin() -> void:
	y = area.size.y / 2.0
	vy = 0.0

func on_tap(_p: Vector2) -> void:
	vy = -620.0
	Sound.tone(600, 0.04, 2, -10.0)

func tick(d: float) -> void:
	tt += d
	vy += 1500.0 * d
	y += vy * d
	spawn_t -= d
	if spawn_t <= 0.0:
		spawn_t = 1.5
		var gap = maxf(95.0, 125.0 - (DURATION - time_left) * 0.8)
		pipes.append([area.size.x + 60.0, rng.randf_range(250.0, area.size.y - 250.0), false, gap])
	flame_t -= d
	if flame_t <= 0.0:
		flame_t = 0.03
		flame.append([Vector2(PX - 30.0, y), Vector2(-120.0, randf_range(-30.0, 30.0)), 0.0])
	for f in flame:
		f[0] += f[1] * d
		f[2] += d
	flame = flame.filter(func(f): return f[2] < 0.3)
	var keep = []
	for p in pipes:
		p[0] -= 280.0 * d
		if absf(p[0] - PX) < 55.0 and absf(y - p[1]) > p[3] - 14.0:
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
	var w = area.size.x
	var h = area.size.y
	for i in 18:
		var sx = fposmod(i * 97.0 - tt * 40.0 * (1.0 + i % 3), w)
		var sy = float((i * 131) % int(maxf(h, 1.0)))
		area.draw_circle(Vector2(sx, sy), 2.0 + i % 3, Color(1, 1, 1, 0.3))
	for p in pipes:
		var top_h = p[1] - p[3]
		var bot_y = p[1] + p[3]
		area.draw_style_box(Games.flat(Color("26de81"), 10), Rect2(p[0] - 50, -10, 100, top_h + 10))
		area.draw_style_box(Games.flat(Color("20bf6b"), 10), Rect2(p[0] - 58, top_h - 30, 116, 30))
		area.draw_style_box(Games.flat(Color("26de81"), 10), Rect2(p[0] - 50, bot_y, 100, h - bot_y + 10))
		area.draw_style_box(Games.flat(Color("20bf6b"), 10), Rect2(p[0] - 58, bot_y, 116, 30))
	for f in flame:
		var a = 1.0 - f[2] / 0.3
		area.draw_circle(f[0], 12.0 * a + 2.0, Color(1.0, 0.65, 0.2, 0.7 * a))
	area.draw_set_transform(Vector2(PX, y), PI / 2.0 + clampf(vy / 1200.0, -0.4, 0.8), Vector2.ONE)
	Games.glyph(area, 12, Vector2.ZERO, 36.0, Color("ff6b6b"))
	area.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
