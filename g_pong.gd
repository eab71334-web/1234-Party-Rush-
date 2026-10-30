extends "res://base.gd"
const PH = 24.0
const PW = 170.0
var ball = Vector2.ZERO
var vel = Vector2.ZERO
var pad_x = [360.0, 360.0]
var sc = [0, 0]
var inited = false

func build() -> void:
	body.draw.connect(paint)
	body.resized.connect(body.queue_redraw)
	say("🏓 حرّك بإصبعك")

func reset(dir: int) -> void:
	ball = body.size / 2.0
	vel = Vector2(randf_range(-250.0, 250.0), 480.0 * dir)

func _input(e: InputEvent) -> void:
	if not (e is InputEventScreenDrag or e is InputEventScreenTouch or e is InputEventMouseMotion or e is InputEventMouseButton):
		return
	if e is InputEventMouseMotion and e.button_mask == 0:
		return
	var p = e.position - body.global_position
	if p.y > body.size.y / 2.0:
		pad_x[0] = clampf(p.x, PW / 2.0, body.size.x - PW / 2.0)
	elif players == 2:
		pad_x[1] = clampf(p.x, PW / 2.0, body.size.x - PW / 2.0)

func _process(d: float) -> void:
	if over or body.size.x <= 0.0:
		return
	if not inited:
		inited = true
		pad_x = [body.size.x / 2.0, body.size.x / 2.0]
		reset(1)
	var W = body.size.x
	var Hh = body.size.y
	ball += vel * d
	if ball.x < 14.0 or ball.x > W - 14.0:
		vel.x = -vel.x
		ball.x = clampf(ball.x, 14.0, W - 14.0)
	if players == 1:
		pad_x[1] = move_toward(pad_x[1], ball.x, 330.0 * d)
	var by = Hh - 70.0
	if vel.y > 0 and ball.y >= by - 14.0 and ball.y <= by + 14.0 and absf(ball.x - pad_x[0]) < PW / 2.0 + 14.0:
		vel.y = -vel.y * 1.06
		vel.x = clampf(vel.x + (ball.x - pad_x[0]) * 4.0, -700.0, 700.0)
		Sound.tone(500, 0.06, 2)
	if vel.y < 0 and ball.y >= 56.0 and ball.y <= 84.0 and absf(ball.x - pad_x[1]) < PW / 2.0 + 14.0:
		vel.y = -vel.y * 1.06
		vel.x = clampf(vel.x + (ball.x - pad_x[1]) * 4.0, -700.0, 700.0)
		Sound.tone(600, 0.06, 2)
	if ball.y > Hh:
		point(1)
	elif ball.y < 0.0:
		point(0)
	body.queue_redraw()

func point(w: int) -> void:
	sc[w] += 1
	Sound.tone(300, 0.2, 1)
	say("%d : %d" % [sc[1], sc[0]])
	if sc[w] >= 5:
		finish("🏆 فاز " + Games.PN[w], col(w))
	else:
		reset(-1 if w == 0 else 1)

func paint() -> void:
	var W = body.size.x
	var Hh = body.size.y
	for i in range(0, int(W), 40):
		body.draw_line(Vector2(i, Hh / 2.0), Vector2(i + 20, Hh / 2.0), Color(1, 1, 1, 0.3), 3.0)
	body.draw_circle(ball, 16.0, Color.WHITE)
	body.draw_style_box(Games.flat(col(0), 12), Rect2(pad_x[0] - PW / 2.0, Hh - 70.0 - PH / 2.0, PW, PH))
	body.draw_style_box(Games.flat(col(1), 12), Rect2(pad_x[1] - PW / 2.0, 70.0 - PH / 2.0, PW, PH))
