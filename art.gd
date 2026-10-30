extends Control
var kind = ""
var idx = 0
var col = Color.WHITE
var t = 0.0
var animate = false:
	set(v):
		animate = v
		set_process(v)
const SYM = [Color("ffb800"), Color("ff3d71"), Color("2ed573"), Color("1e90ff"), Color("a55eea"), Color("ff7f50"), Color("f7d51d"), Color("ff6b9d"), Color("00cec9"), Color("6ab04c")]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(animate)
	resized.connect(queue_redraw)

func _process(d: float) -> void:
	t += d
	queue_redraw()

func U() -> float:
	return minf(size.x, size.y)

func P(x: float, y: float) -> Vector2:
	return Vector2(size.x / 2.0 + x * U(), size.y / 2.0 + y * U())

func Q(x: float, y: float) -> Vector2:
	return Vector2(x * U(), y * U())

func rr(cx: float, cy: float, w: float, h: float, c: Color, r: float = 0.05) -> void:
	draw_style_box(Games.flat(c, int(r * U())), Rect2(P(cx - w / 2.0, cy - h / 2.0), Vector2(w * U(), h * U())))

func circ(x: float, y: float, r: float, c: Color) -> void:
	draw_circle(P(x, y), r * U(), c)

func ln(x1: float, y1: float, x2: float, y2: float, c: Color, w: float = 0.04) -> void:
	draw_line(P(x1, y1), P(x2, y2), c, w * U())

func poly(pts: Array, c: Color) -> void:
	var a = PackedVector2Array()
	for i in range(0, pts.size(), 2):
		a.append(P(pts[i], pts[i + 1]))
	draw_colored_polygon(a, c)

func txt(s: String, x: float, y: float, fs: float, c: Color) -> void:
	var p = P(x, y)
	draw_string(ThemeDB.fallback_font, Vector2(p.x - 200.0, p.y + fs * U() * 0.35), s, HORIZONTAL_ALIGNMENT_CENTER, 400.0, int(fs * U()), c)

func ell(x: float, y: float, rx: float, ry: float, c: Color) -> void:
	draw_set_transform(P(x, y), 0.0, Vector2(1.0, ry / rx))
	draw_circle(Vector2.ZERO, rx * U(), c)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func sector(a0: float, a1: float, r0: float, r1: float, c: Color) -> void:
	var pts = PackedVector2Array()
	for i in 9:
		var a = lerpf(a0, a1, i / 8.0)
		pts.append(P(cos(a) * r1, sin(a) * r1))
	for i in 9:
		var a = lerpf(a1, a0, i / 8.0)
		pts.append(P(cos(a) * r0, sin(a) * r0))
	draw_colored_polygon(pts, c)

func _draw() -> void:
	var f = "d_" + kind
	if has_method(f):
		call(f)
	else:
		d_gen()

func d_sym() -> void:
	Games.glyph(self, idx % 31, P(0, 0), U() * 0.34, SYM[idx % 10])

func d_logo() -> void:
	var cs = Games.PC
	var w = size.x * 0.19
	var h = w * 1.25
	for i in 4:
		var by = sin(t * 2.5 + i * 0.9) * 14.0
		var rot = sin(t * 1.7 + i) * 0.1
		var x = size.x / 2.0 + (i - 1.5) * size.x * 0.235
		draw_set_transform(Vector2(x, size.y / 2.0 + by), rot, Vector2.ONE)
		draw_style_box(Games.style(cs[i], int(w * 0.25), 10), Rect2(Vector2(-w / 2.0, -h / 2.0), Vector2(w, h)))
		draw_string(ThemeDB.fallback_font, Vector2(-w / 2.0, h * 0.22), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, w, int(w * 0.8), Color.WHITE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func d_chess() -> void:
	rr(0, 0, 0.9, 0.9, Color("3b2a1a"), 0.07)
	for i in 4:
		for j in 4:
			var c = Color("f0dcb4") if (i + j) % 2 == 0 else Color("b5834f")
			draw_rect(Rect2(P(-0.4 + i * 0.2, -0.4 + j * 0.2), Vector2(0.2 * U(), 0.2 * U())), c)
	Games.piece(self, "N", P(-0.1, 0.0 + sin(t * 2.0) * 0.012), U() * 0.78, Color("f4f4f6"))
	Games.piece(self, "K", P(0.2, 0.2), U() * 0.45, Color("34343c"))

func d_xo() -> void:
	for v in [-0.17, 0.17]:
		ln(v, -0.42, v, 0.42, Color(1, 1, 1, 0.7), 0.03)
		ln(-0.42, v, 0.42, v, Color(1, 1, 1, 0.7), 0.03)
	var pulse = 1.0 + sin(t * 4.0) * 0.06
	for v in [Vector2(-0.3, -0.3), Vector2(0.3, 0.0), Vector2(-0.3, 0.3)]:
		ln(v.x - 0.08, v.y - 0.08, v.x + 0.08, v.y + 0.08, Color("ff4d6d"), 0.05)
		ln(v.x + 0.08, v.y - 0.08, v.x - 0.08, v.y + 0.08, Color("ff4d6d"), 0.05)
	for v in [Vector2(0.0, 0.0), Vector2(0.3, -0.3), Vector2(0.0, 0.3)]:
		draw_arc(P(v.x, v.y), 0.09 * U() * pulse, 0, TAU, 28, Color("4dc3ff"), 0.05 * U())

func d_c4() -> void:
	rr(0, 0.02, 0.9, 0.72, Color("2b57d6"), 0.07)
	var cols = [Color("ff4757"), Color("ffd32a")]
	for i in 5:
		for j in 4:
			var c = Color("10215e")
			if j == 3:
				c = cols[i % 2]
			elif j == 2 and i in [1, 2, 3]:
				c = cols[(i + 1) % 2]
			circ(-0.32 + i * 0.16, -0.17 + j * 0.16, 0.065, c)
	var fy = -0.42 + fposmod(t * 0.6, 1.0) * 0.25
	circ(0.0, fy, 0.065, cols[0])

func d_tap() -> void:
	for i in 3:
		var k = fposmod(t * 0.8 + i * 0.33, 1.0)
		draw_arc(P(0, 0), (0.2 + k * 0.28) * U(), 0, TAU, 40, Color(1, 1, 1, 0.5 * (1.0 - k)), 0.02 * U())
	circ(0, 0, 0.24 * (1.0 + sin(t * 6.0) * 0.04), Color("ffd166"))
	poly([0.04, -0.2, -0.12, 0.03, -0.01, 0.03, -0.06, 0.2, 0.12, -0.06, 0.01, -0.06], Color("e8590c"))

func d_memory() -> void:
	for i in 4:
		var x = -0.2 + (i % 2) * 0.4
		var y = -0.2 + (i / 2) * 0.4
		var up = (i == 0 or i == 3)
		draw_set_transform(P(x, y), (i - 1.5) * 0.08, Vector2.ONE)
		draw_style_box(Games.style(Color("f5f6fa") if up else Color("7d3fd0"), int(0.05 * U()), int(0.015 * U())), Rect2(Q(-0.17, -0.2), Vector2(0.34 * U(), 0.4 * U())))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if up:
			var n = 0 if i == 0 else 1
			var c0 = P(x, y)
			var r = U() * 0.1
			var k = SYM[n]
			if n == 0:
				var pts = PackedVector2Array()
				for j in 10:
					var a = -PI / 2.0 + j * PI / 5.0
					pts.append(c0 + Vector2(cos(a), sin(a)) * (r if j % 2 == 0 else r * 0.45))
				draw_colored_polygon(pts, k)
			else:
				draw_circle(c0 + Vector2(-0.5, -0.3) * r, r * 0.58, k)
				draw_circle(c0 + Vector2(0.5, -0.3) * r, r * 0.58, k)
				draw_colored_polygon(PackedVector2Array([c0 + Vector2(-1.04, -0.05) * r, c0 + Vector2(1.04, -0.05) * r, c0 + Vector2(0, 1.0) * r]), k)
		else:
			txt("?", x, y, 0.2, Color(1, 1, 1, 0.9))

func d_snake() -> void:
	var n = 13
	for i in n:
		var x = -0.4 + i * 0.065
		var y = sin(i * 0.55 + t * 3.0) * 0.13
		var r = 0.055 + i * 0.002
		circ(x, y + 0.04, r, Color("1fa855").lerp(Color("5df29a"), i / float(n)))
	var hx = -0.4 + (n - 1) * 0.065
	var hy = sin((n - 1) * 0.55 + t * 3.0) * 0.13 + 0.04
	circ(hx + 0.02, hy, 0.08, Color("7dffb0"))
	circ(hx + 0.03, hy - 0.03, 0.02, Color.BLACK)
	circ(hx + 0.03, hy + 0.03, 0.02, Color.BLACK)
	circ(0.37, -0.25 + sin(t * 4.0) * 0.01, 0.07, Color("ff3b3b"))
	ln(0.37, -0.32, 0.4, -0.38, Color("5c8a2e"), 0.02)

func d_2048() -> void:
	var vals = ["2", "4", "8", "16"]
	var cs = [Color("eee4da"), Color("f2b179"), Color("f67c5f"), Color("edc22e")]
	for i in 4:
		var x = -0.21 + (i % 2) * 0.42
		var y = -0.21 + (i / 2) * 0.42
		var s = 1.0 + (0.05 * sin(t * 3.0 + i) if animate else 0.0)
		rr(x, y, 0.38 * s, 0.38 * s, cs[i], 0.06)
		txt(vals[i], x, y, 0.17, Color("5a4a3a") if i == 0 else Color.WHITE)

func d_react() -> void:
	rr(0, 0, 0.38, 0.9, Color("1b1b2b"), 0.12)
	var lit = int(t * 1.5) % 3
	var cs = [Color("ff4757"), Color("ffc312"), Color("2ed573")]
	for i in 3:
		var on = (i == lit)
		var c = cs[i] if on else cs[i].darkened(0.7)
		if on:
			circ(0, -0.27 + i * 0.27, 0.19, Color(c.r, c.g, c.b, 0.3))
		circ(0, -0.27 + i * 0.27, 0.11, c)

func d_tug() -> void:
	var off = sin(t * 2.5) * 0.08
	ln(-0.38, 0.0, 0.38, 0.0, Color("d9b382"), 0.045)
	poly([off - 0.04, 0.0, off + 0.12, -0.1, off - 0.04, -0.2], Color("ff4757"))
	ln(off - 0.04, 0.0, off - 0.04, -0.2, Color("ddd"), 0.02)
	for s in [-1, 1]:
		var c = Color("4dc3ff") if s < 0 else Color("ff6b81")
		circ(s * 0.36, -0.1, 0.07, c)
		ln(s * 0.36, -0.03, s * 0.3, 0.12, c, 0.06)
		ln(s * 0.3, 0.12, s * 0.33, 0.3, c, 0.05)
		ln(s * 0.36, 0.0, s * 0.2, 0.0, c, 0.05)

func d_rps() -> void:
	var b = sin(t * 3.0) * 0.015
	circ(-0.3, 0.0 + b, 0.13, Color("9aa5b1"))
	circ(-0.34, -0.04 + b, 0.04, Color("c8d0d8"))
	rr(0.0, 0.0 - b, 0.22, 0.3, Color("f5f6fa"), 0.04)
	for i in 3:
		ln(-0.06, -0.08 + i * 0.08 - b, 0.06, -0.08 + i * 0.08 - b, Color("b2bec3"), 0.015)
	ln(0.22, 0.12 + b, 0.38, -0.12 + b, Color("e84118"), 0.04)
	ln(0.38, 0.12 + b, 0.22, -0.12 + b, Color("e84118"), 0.04)
	draw_arc(P(0.22, 0.17 + b), 0.04 * U(), 0, TAU, 12, Color("dcdde1"), 0.025 * U())
	draw_arc(P(0.38, 0.17 + b), 0.04 * U(), 0, TAU, 12, Color("dcdde1"), 0.025 * U())

func d_guess() -> void:
	var rs = [0.34, 0.26, 0.18, 0.1]
	for i in 4:
		circ(0, 0.04, rs[i], Color("ff4757") if i % 2 == 0 else Color("f5f6fa"))
	var k = sin(t * 3.0) * 0.02
	ln(0.34 + k, -0.34 - k, 0.02, 0.06, Color("2f3542"), 0.03)
	ln(0.34 + k, -0.34 - k, 0.42 + k, -0.4 - k, Color("ffa502"), 0.07)

func d_pong() -> void:
	for i in 8:
		ln(-0.42 + i * 0.12, 0.0, -0.34 + i * 0.12, 0.0, Color(1, 1, 1, 0.3), 0.02)
	rr(0.0, -0.38, 0.28, 0.06, Color("ff6b81"), 0.03)
	rr(sin(t * 1.4) * 0.15, 0.38, 0.28, 0.06, Color("4dc3ff"), 0.03)
	var bx = sin(t * 2.0) * 0.3
	var by = cos(t * 3.0) * 0.2
	for i in 4:
		circ(bx - i * 0.03, by + i * 0.02, 0.05 - i * 0.01, Color(1, 1, 1, 0.5 - i * 0.12))
	circ(bx, by, 0.055, Color.WHITE)

func d_whack() -> void:
	var p = 0.5 + 0.5 * sin(t * 3.0)
	ell(0, 0.22, 0.34, 0.12, Color("2a1a0a"))
	circ(0, 0.12 - p * 0.2, 0.2, Color("8d5524"))
	circ(-0.07, 0.07 - p * 0.2, 0.03, Color.BLACK)
	circ(0.07, 0.07 - p * 0.2, 0.03, Color.BLACK)
	circ(0, 0.14 - p * 0.2, 0.05, Color("ff9ff3"))
	ell(0, 0.27, 0.36, 0.1, Color("6d4c2b"))

func d_gomoku() -> void:
	rr(0, 0, 0.9, 0.9, Color("deb068"), 0.05)
	for i in 5:
		ln(-0.32, -0.32 + i * 0.16, 0.32, -0.32 + i * 0.16, Color("5c3d12"), 0.012)
		ln(-0.32 + i * 0.16, -0.32, -0.32 + i * 0.16, 0.32, Color("5c3d12"), 0.012)
	for i in 5:
		circ(-0.32 + i * 0.16, -0.32 + i * 0.16, 0.068, Color("1e1e1e") if i != int(t * 2.0) % 5 else Color("ffd32a"))
	for v in [Vector2(2, 0), Vector2(3, 1), Vector2(1, 3), Vector2(0, 2)]:
		circ(-0.32 + v.x * 0.16, -0.32 + v.y * 0.16, 0.068, Color("f5f6fa"))

func d_reversi() -> void:
	rr(0, 0, 0.9, 0.9, Color("1e8449"), 0.06)
	for i in 4:
		ln(-0.3 + i * 0.2, -0.3, -0.3 + i * 0.2, 0.3, Color(0, 0, 0, 0.4), 0.012)
		ln(-0.3, -0.3 + i * 0.2, 0.3, -0.3 + i * 0.2, Color(0, 0, 0, 0.4), 0.012)
	var k = cos(t * 3.0)
	for v in [Vector2(0, 0), Vector2(1, 1), Vector2(2, 0), Vector2(0, 2), Vector2(2, 2)]:
		var c = Color.BLACK if int(v.x + v.y) % 2 == 0 else Color("f5f6fa")
		ell(-0.2 + v.x * 0.2, -0.2 + v.y * 0.2, 0.075, 0.075 * (absf(k) if v == Vector2(1, 1) else 1.0), c)

func d_dice() -> void:
	d_die()

func d_die() -> void:
	var n = idx if idx > 0 else 5
	draw_set_transform(P(0, 0), sin(t * 2.0) * 0.18 - 0.1 if animate else 0.0, Vector2.ONE)
	draw_style_box(Games.style(Color("f5f6fa"), int(0.12 * U()), int(0.03 * U())), Rect2(Q(-0.34, -0.34), Vector2(0.68 * U(), 0.66 * U())))
	var spots = {1: [0, 0], 2: [-1, -1, 1, 1], 3: [-1, -1, 0, 0, 1, 1], 4: [-1, -1, 1, -1, -1, 1, 1, 1], 5: [-1, -1, 1, -1, 0, 0, -1, 1, 1, 1], 6: [-1, -1, 1, -1, -1, 0, 1, 0, -1, 1, 1, 1]}
	var s = spots[n]
	for i in range(0, s.size(), 2):
		draw_circle(Q(s[i] * 0.17, s[i + 1] * 0.17 - 0.015), 0.055 * U(), Color("2d3436"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func d_math() -> void:
	var sy = ["+", "-", "×", "÷"]
	var cs = [Color("ff6b6b"), Color("feca57"), Color("48dbfb"), Color("1dd1a1")]
	for i in 4:
		var x = -0.2 + (i % 2) * 0.4
		var y = -0.2 + (i / 2) * 0.4
		var b = sin(t * 3.0 + i * 1.3) * 0.02
		circ(x, y + b, 0.17, cs[i])
		txt(sy[i], x, y + b, 0.26, Color.WHITE)

func d_simon() -> void:
	var cs = [Color("ff4757"), Color("2ed573"), Color("1e90ff"), Color("ffa502")]
	var lit = int(t * 2.0) % 4
	for i in 4:
		var a0 = i * PI / 2.0 + 0.06
		var c = cs[i] if i == lit else cs[i].darkened(0.35)
		sector(a0, a0 + PI / 2.0 - 0.12, 0.12, 0.44, c)
	circ(0, 0, 0.1, Color("2f3542"))

func d_slide() -> void:
	for i in 9:
		if i == 8:
			continue
		var x = -0.3 + (i % 3) * 0.3
		var y = -0.3 + (i / 3) * 0.3
		rr(x, y, 0.27, 0.27, Color("ff6b81").lerp(Color("ffa502"), i / 8.0), 0.05)
		txt(str(i + 1), x, y, 0.15, Color.WHITE)

func d_lights() -> void:
	var step = int(t * 1.5) % 4
	for i in 9:
		var x = -0.3 + (i % 3) * 0.3
		var y = -0.3 + (i / 3) * 0.3
		var on = ((i + step) % 3 == 0) or i == 4
		if on:
			circ(x, y, 0.15, Color(1, 0.85, 0.2, 0.3))
		circ(x, y, 0.1, Color("ffd32a") if on else Color("3b3b55"))

func d_rps_hidden() -> void:
	circ(0, 0, 0.3, Color(1, 1, 1, 0.15))
	txt("?", 0, 0, 0.4, Color(1, 1, 1, 0.8))

func d_rps_rock() -> void:
	circ(0, 0.02, 0.3, Color("8d99a6"))
	circ(-0.1, -0.1, 0.09, Color("c3ccd5"))
	circ(0.1, 0.1, 0.05, Color("707b87"))

func d_rps_paper() -> void:
	rr(0, 0, 0.5, 0.64, Color("f5f6fa"), 0.06)
	for i in 4:
		ln(-0.15, -0.2 + i * 0.13, 0.15, -0.2 + i * 0.13, Color("b2bec3"), 0.025)

func d_rps_scissors() -> void:
	ln(-0.25, 0.3, 0.2, -0.3, Color("dfe4ea"), 0.07)
	ln(0.25, 0.3, -0.2, -0.3, Color("dfe4ea"), 0.07)
	draw_arc(P(-0.2, 0.3), 0.09 * U(), 0, TAU, 14, Color("ff4757"), 0.05 * U())
	draw_arc(P(0.2, 0.3), 0.09 * U(), 0, TAU, 14, Color("ff4757"), 0.05 * U())

func d_rps_hand() -> void:
	txt("?", 0, 0, 0.3, Color(1, 1, 1, 0.5))

func d_mole() -> void:
	circ(0, 0, 0.42, Color("8d5524"))
	circ(-0.15, -0.08, 0.06, Color.BLACK)
	circ(0.15, -0.08, 0.06, Color.BLACK)
	circ(-0.13, -0.1, 0.02, Color.WHITE)
	circ(0.17, -0.1, 0.02, Color.WHITE)
	circ(0, 0.08, 0.1, Color("ff9ff3"))
	circ(-0.26, -0.3, 0.1, Color("8d5524"))
	circ(0.26, -0.3, 0.1, Color("8d5524"))
	rr(0, 0.22, 0.2, 0.08, Color("f5f6fa"), 0.03)

func d_boom() -> void:
	for i in 8:
		var a = i * TAU / 8.0
		ln(cos(a) * 0.15, sin(a) * 0.15, cos(a) * 0.4, sin(a) * 0.4, Color("ffd32a"), 0.07)
	circ(0, 0, 0.2, Color("ff6348"))

func d_gear() -> void:
	for i in 8:
		var a = i * TAU / 8.0
		draw_line(P(cos(a) * 0.2, sin(a) * 0.2), P(cos(a) * 0.34, sin(a) * 0.34), col, 0.13 * U())
	draw_arc(P(0, 0), 0.21 * U(), 0, TAU, 32, col, 0.11 * U())

func d_snd_on() -> void:
	poly([-0.3, -0.12, -0.15, -0.12, 0.03, -0.28, 0.03, 0.28, -0.15, 0.12, -0.3, 0.12], col)
	draw_arc(P(0.05, 0), 0.17 * U(), -0.8, 0.8, 12, col, 0.06 * U())
	draw_arc(P(0.05, 0), 0.3 * U(), -0.8, 0.8, 12, col, 0.06 * U())

func d_snd_off() -> void:
	poly([-0.3, -0.12, -0.15, -0.12, 0.03, -0.28, 0.03, 0.28, -0.15, 0.12, -0.3, 0.12], col)
	ln(0.14, -0.14, 0.4, 0.14, col, 0.07)
	ln(0.4, -0.14, 0.14, 0.14, col, 0.07)

func d_music() -> void:
	circ(-0.1, 0.2, 0.12, col)
	ln(0.01, 0.2, 0.01, -0.28, col, 0.07)
	poly([0.01, -0.28, 0.26, -0.15, 0.26, -0.03, 0.01, -0.14], col)

func d_close() -> void:
	ln(-0.22, -0.22, 0.22, 0.22, col, 0.09)
	ln(0.22, -0.22, -0.22, 0.22, col, 0.09)

func d_play() -> void:
	poly([-0.15, -0.28, 0.3, 0.0, -0.15, 0.28], col)

func d_lang() -> void:
	txt("Aع", 0, 0, 0.42, col)

func d_fps() -> void:
	txt("FPS", 0, 0, 0.32, col)

func d_gen() -> void:
	var n = 10
	for i in n:
		var a = i * TAU / n + t * 0.25
		var l = 0.5 + 0.1 * sin(t * 2.0 + i)
		draw_line(P(0, 0), P(cos(a) * l, sin(a) * l), Color(1, 1, 1, 0.07), 0.07 * U())
	for i in 4:
		var a = t * 0.8 + i * PI / 2.0
		Games.glyph(self, (idx + i * 7 + 3) % 31, P(cos(a) * 0.36, sin(a) * 0.34), U() * 0.06, Color(1, 1, 1, 0.45))
	var bob = sin(t * 2.0) * 0.015
	Games.glyph(self, idx % 31, P(0, bob), U() * 0.26, col if col != Color.WHITE else Color("ffd166"))

func d_arrow() -> void:
	draw_set_transform(P(0, 0), idx * PI / 2.0, Vector2.ONE)
	var r = U() * 0.34
	draw_colored_polygon(PackedVector2Array([Vector2(0, -1) * r, Vector2(0.8, 0) * r, Vector2(0.35, 0) * r, Vector2(0.35, 1) * r, Vector2(-0.35, 1) * r, Vector2(-0.35, 0) * r, Vector2(-0.8, 0) * r]), col)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func d_dots() -> void:
	var pos = [Vector2(-0.3, -0.25), Vector2(0.2, -0.3), Vector2(0.32, 0.1), Vector2(-0.1, 0.05), Vector2(-0.32, 0.3), Vector2(0.1, 0.32), Vector2(0.0, -0.05), Vector2(-0.35, 0.0), Vector2(0.35, -0.3), Vector2(0.28, 0.34)]
	var seq = [0, 5, 2, 8, 3, 9, 1, 6, 4, 7]
	for i in idx:
		draw_circle(P(pos[seq[i % 10]].x, pos[seq[i % 10]].y), 0.07 * U(), col)
