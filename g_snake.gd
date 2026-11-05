extends "res://base.gd"
const W = 16
const H = 22
var snake = []
var prev = []
var dir = Vector2i(1, 0)
var queue = []
var food = Vector2i(8, 5)
var acc = 0.0
var step = 0.15
var score = 0
var best = 0
var org = Vector2.ZERO
var cs = 30.0
var start = null
var tt = 0.0
var parts = []

func build() -> void:
	canvas(paint, inp)
	snake = [Vector2i(5, 10), Vector2i(4, 10), Vector2i(3, 10)]
	prev = snake.duplicate()
	place_food()
	var c = ConfigFile.new()
	if c.load("user://snake.cfg") == OK:
		best = int(c.get_value("s", "best", 0))
	status()

func status() -> void:
	say("🐍 %s: %d   %s: %d" % [Games.L("النتيجة", "Score"), score, Games.L("الأفضل", "Best"), best])

func place_food() -> void:
	while true:
		food = Vector2i(randi() % W, randi() % H)
		if not snake.has(food):
			break

func burst(cell: Vector2i) -> void:
	for i in 10:
		var a = randf() * TAU
		parts.append([Vector2(cell) + Vector2(0.5, 0.5), Vector2(cos(a), sin(a)) * randf_range(2.0, 5.0), 0.0])

func _process(d: float) -> void:
	super._process(d)
	tt += d
	for p in parts:
		p[0] += p[1] * d
		p[2] += d
	parts = parts.filter(func(p): return p[2] < 0.5)
	if over:
		if not parts.is_empty():
			body.queue_redraw()
		return
	acc += d
	if acc >= step:
		acc -= step
		advance()
	body.queue_redraw()

func advance() -> void:
	if not queue.is_empty():
		dir = queue.pop_front()
	var head = snake[0] + dir
	var eating = head == food
	var solid = snake if eating else snake.slice(0, snake.size() - 1)
	if head.x < 0 or head.y < 0 or head.x >= W or head.y >= H or solid.has(head):
		Sound.lose()
		if score > best:
			best = score
			var c = ConfigFile.new()
			c.set_value("s", "best", best)
			c.save("user://snake.cfg")
		finish("💥 %s: %d" % [Games.L("النتيجة", "Score"), score], Color("ff7675"))
		return
	prev = snake.duplicate()
	snake.push_front(head)
	if eating:
		score += 1
		burst(food)
		Sound.tone(700 + score * 20, 0.1, 2)
		step = maxf(0.07, 0.15 - score * 0.003)
		place_food()
		status()
	else:
		snake.pop_back()

func inp(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		start = e.position if e.pressed else null
	elif e is InputEventMouseMotion and start != null:
		var d = e.position - start
		if d.length() > 36.0:
			var n = Vector2i(0, 0)
			if absf(d.x) > absf(d.y):
				n = Vector2i(1 if d.x > 0 else -1, 0)
			else:
				n = Vector2i(0, 1 if d.y > 0 else -1)
			var ref = queue.back() if not queue.is_empty() else dir
			if n != -ref and n != ref and queue.size() < 2:
				queue.append(n)
			start = e.position

func paint() -> void:
	cs = minf(body.size.x / W, body.size.y / H)
	org = Vector2((body.size.x - cs * W) / 2.0, (body.size.y - cs * H) / 2.0)
	body.draw_style_box(Games.flat(Color(0, 0, 0, 0.35), 24), Rect2(org, Vector2(cs * W, cs * H)))
	for y in H:
		for x in W:
			if (x + y) % 2 == 0:
				body.draw_rect(Rect2(org + Vector2(x, y) * cs, Vector2(cs, cs)), Color(1, 1, 1, 0.04))
	var fc = org + (Vector2(food) + Vector2(0.5, 0.5)) * cs
	var pulse = 1.0 + sin(tt * 6.0) * 0.08
	body.draw_circle(fc, cs * 0.4 * pulse, Color("ff5d73"))
	body.draw_circle(fc + Vector2(-0.12, -0.12) * cs, cs * 0.1, Color(1, 1, 1, 0.5))
	body.draw_line(fc + Vector2(0, -0.35) * cs, fc + Vector2(0.12, -0.5) * cs, Color("5c8a2e"), cs * 0.08)
	var k = 1.0 if over else clampf(acc / step, 0.0, 1.0)
	var n = snake.size()
	for i in range(n - 1, -1, -1):
		var to_p = Vector2(snake[i])
		var from_p = Vector2(prev[i]) if i < prev.size() else Vector2(prev[prev.size() - 1])
		var p = from_p.lerp(to_p, k)
		var c = org + (p + Vector2(0.5, 0.5)) * cs
		var rad = cs * (0.46 - 0.1 * float(i) / maxf(n, 1))
		var colr = Color("b8ffd9") if i == 0 else Color("3ddc97").darkened(0.45 * float(i) / maxf(n, 1))
		body.draw_circle(c, rad, colr)
		if i == 0:
			var dv = Vector2(dir)
			var perp = Vector2(-dv.y, dv.x)
			for s in [-1.0, 1.0]:
				var ep = c + dv * cs * 0.14 + perp * s * cs * 0.18
				body.draw_circle(ep, cs * 0.1, Color.WHITE)
				body.draw_circle(ep + dv * cs * 0.03, cs * 0.05, Color.BLACK)
	for p in parts:
		var a = 1.0 - p[2] / 0.5
		body.draw_circle(org + p[0] * cs, cs * 0.1 * a + 1.0, Color(1, 0.45, 0.5, a))
