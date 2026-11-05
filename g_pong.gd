extends "res://base.gd"
const PH = 24.0
const PW = 170.0
var ball = Vector2.ZERO
var vel = Vector2.ZERO
var pad_x = [360.0, 360.0]
var sc = [0, 0]
var inited = false
var serve_t = 0.0
var trail = []
var flash = [0.0, 0.0]
var fz = {}

func build() -> void:
	body.draw.connect(paint)
	body.resized.connect(body.queue_redraw)
	say("🏓 حرّك بإصبعك")

func reset(dir: int) -> void:
	ball = body.size / 2.0
	vel = Vector2(randf_range(-250.0, 250.0), 480.0 * dir)
	serve_t = 0.9
	trail = []

func zone_of(pos: Vector2) -> int:
	if players == 1:
		return 0
	var local_y = pos.y - body.global_position.y
	return 0 if local_y > body.size.y / 2.0 else 1

func move_pad(z: int, pos: Vector2) -> void:
	var x = pos.x - body.global_position.x
	pad_x[z] = clampf(x, PW / 2.0, body.size.x - PW / 2.0)

func _input(e: InputEvent) -> void:
	if e is InputEventScreenTouch:
		if e.pressed:
			fz[e.index] = zone_of(e.position)
			move_pad(fz[e.index], e.position)
		else:
			fz.erase(e.index)
	elif e is InputEventScreenDrag:
		if fz.has(e.index):
			move_pad(fz[e.index], e.position)
	elif not DisplayServer.is_touchscreen_available():
		if e is InputEventMouseMotion and e.button_mask != 0:
			move_pad(zone_of(e.position), e.position)
		elif e is InputEventMouseButton and e.pressed:
			move_pad(zone_of(e.position), e.position)

func _process(d: float) -> void:
	if over or body.size.x <= 0.0:
		return
	if not inited:
		inited = true
		pad_x = [body.size.x / 2.0, body.size.x / 2.0]
		reset(1)
	for k in 2:
		flash[k] = maxf(0.0, flash[k] - d * 4.0)
	if serve_t > 0.0:
		serve_t -= d
		body.queue_redraw()
		return
	var W = body.size.x
	var Hh = body.size.y
	var old = ball
	ball += vel * d
	trail.append(ball)
	if trail.size() > 10:
		trail.pop_front()
	if ball.x < 14.0 or ball.x > W - 14.0:
		vel.x = -vel.x
		ball.x = clampf(ball.x, 14.0, W - 14.0)
	if players == 1:
		var target = ball.x if vel.y < 0.0 else W / 2.0
		pad_x[1] = move_toward(pad_x[1], target, 330.0 * d)
	var by = Hh - 70.0
	var ty = 70.0
	if vel.y > 0 and old.y <= by + 14.0 and ball.y >= by - 14.0 and absf(ball.x - pad_x[0]) < PW / 2.0 + 14.0:
		vel.y = clampf(-vel.y * 1.06, -1100.0, 1100.0)
		vel.x = clampf(vel.x + (ball.x - pad_x[0]) * 4.0, -700.0, 700.0)
		ball.y = by - 14.0
		flash[0] = 1.0
		Sound.tone(500, 0.06, 2)
	if vel.y < 0 and old.y >= ty - 14.0 and ball.y <= ty + 14.0 and absf(ball.x - pad_x[1]) < PW / 2.0 + 14.0:
		vel.y = clampf(-vel.y * 1.06, -1100.0, 1100.0)
		vel.x = clampf(vel.x + (ball.x - pad_x[1]) * 4.0, -700.0, 700.0)
		ball.y = ty + 14.0
		flash[1] = 1.0
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
	var f = ThemeDB.fallback_font
	body.draw_string(f, Vector2(0, Hh * 0.38), str(sc[1]), HORIZONTAL_ALIGNMENT_CENTER, W, 160, Color(1, 1, 1, 0.1))
	body.draw_string(f, Vector2(0, Hh * 0.72), str(sc[0]), HORIZONTAL_ALIGNMENT_CENTER, W, 160, Color(1, 1, 1, 0.1))
	for i in range(0, int(W), 40):
		body.draw_line(Vector2(i, Hh / 2.0), Vector2(i + 20, Hh / 2.0), Color(1, 1, 1, 0.3), 3.0)
	for i in trail.size():
		var a = float(i) / maxf(trail.size(), 1)
		body.draw_circle(trail[i], 16.0 * a, Color(1, 1, 1, 0.25 * a))
	var br = 16.0
	if serve_t > 0.0:
		br = 16.0 + sin(serve_t * 14.0) * 3.0
	body.draw_circle(ball, br, Color.WHITE)
	body.draw_style_box(Games.flat(col(0).lightened(flash[0] * 0.5), 12), Rect2(pad_x[0] - PW / 2.0, Hh - 70.0 - PH / 2.0, PW, PH))
	body.draw_style_box(Games.flat(col(1).lightened(flash[1] * 0.5), 12), Rect2(pad_x[1] - PW / 2.0, 70.0 - PH / 2.0, PW, PH))
