extends "res://base.gd"
const W = 16
const H = 22
var snake = []
var dir = Vector2i(1, 0)
var nd = Vector2i(1, 0)
var food = Vector2i(8, 5)
var acc = 0.0
var score = 0
var org = Vector2.ZERO
var start = null

func build() -> void:
	canvas(paint, inp)
	snake = [Vector2i(5, 10), Vector2i(4, 10), Vector2i(3, 10)]
	place_food()
	say("🐍 اسحب لتغيير الاتجاه")

func place_food() -> void:
	while true:
		food = Vector2i(randi() % W, randi() % H)
		if not snake.has(food):
			break

func _process(d: float) -> void:
	if over:
		return
	acc += d
	var step = maxf(0.07, 0.15 - score * 0.003)
	if acc >= step:
		acc = 0.0
		advance()

func advance() -> void:
	dir = nd
	var head = snake[0] + dir
	if head.x < 0 or head.y < 0 or head.x >= W or head.y >= H or snake.has(head):
		Sound.lose()
		finish("💥 النتيجة: %d" % score, Color("ff7675"))
		return
	snake.push_front(head)
	if head == food:
		score += 1
		Sound.tone(700 + score * 20, 0.1, 2)
		say("🐍 النتيجة: %d" % score)
		place_food()
	else:
		snake.pop_back()
	body.queue_redraw()

func inp(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		start = e.position if e.pressed else null
	elif e is InputEventMouseMotion and start != null:
		var d = e.position - start
		if d.length() > 40.0:
			var n = Vector2i(0, 0)
			if absf(d.x) > absf(d.y):
				n = Vector2i(1 if d.x > 0 else -1, 0)
			else:
				n = Vector2i(0, 1 if d.y > 0 else -1)
			if n != -dir:
				nd = n
			start = e.position

func paint() -> void:
	var f = minf(body.size.x / W, body.size.y / H)
	org = Vector2((body.size.x - f * W) / 2.0, (body.size.y - f * H) / 2.0)
	body.draw_style_box(Games.flat(Color(0, 0, 0, 0.35), 24), Rect2(org, Vector2(f * W, f * H)))
	body.draw_circle(org + (Vector2(food) + Vector2(0.5, 0.5)) * f, f * 0.38, Color("ff5d73"))
	for i in snake.size():
		var s = snake[i]
		var c = Color("3ddc97") if i > 0 else Color("b8ffd9")
		body.draw_style_box(Games.flat(c, int(f * 0.4)), Rect2(org + Vector2(s) * f + Vector2(2, 2), Vector2(f - 4, f - 4)))
