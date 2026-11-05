extends "res://race.gd"
var blocks = []
var cur_x = 0.0
var cur_w = 300.0
var dirn = 1.0
var speed = 380.0
var streak = 0
var debris = []
var fx_t = 0.0
const BH = 56.0

func setup() -> void:
	area.draw.connect(paint)

func hint_text() -> String:
	return Games.L("اضغط لإسقاط الكتلة بدقة", "Tap to drop the block precisely")

func begin() -> void:
	blocks = [[area.size.x / 2.0 - 150.0, 300.0]]
	cur_w = 300.0
	cur_x = 0.0

func tick(d: float) -> void:
	cur_x += dirn * speed * d
	if cur_x < 0.0:
		cur_x = 0.0
		dirn = 1.0
	if cur_x + cur_w > area.size.x:
		cur_x = area.size.x - cur_w
		dirn = -1.0
	fx_t = maxf(0.0, fx_t - d * 1.5)
	for b in debris:
		b[4] += 1800.0 * d
		b[3] += b[4] * d
	debris = debris.filter(func(b): return b[3] < 700.0)
	area.queue_redraw()

func on_tap(_p: Vector2) -> void:
	if blocks.is_empty():
		return
	var last = blocks.back()
	var l = maxf(cur_x, last[0])
	var r = minf(cur_x + cur_w, last[0] + last[1])
	if r - l < 12.0:
		debris.append([cur_x, cur_w, blocks.size(), 0.0, 0.0])
		Sound.lose()
		end_round()
		return
	var perfect = absf(cur_x - last[0]) < 8.0
	if perfect:
		l = last[0]
		r = last[0] + last[1]
		streak += 1
		fx_t = 1.0
		if streak >= 3 and (r - l) < 300.0:
			var w0 = r - l
			var nw = minf(300.0, w0 + 12.0)
			l = clampf(l - (nw - w0) / 2.0, 0.0, area.size.x - nw)
			r = l + nw
	else:
		streak = 0
		if cur_x < last[0]:
			debris.append([cur_x, last[0] - cur_x, blocks.size(), 0.0, 0.0])
		if cur_x + cur_w > last[0] + last[1]:
			debris.append([last[0] + last[1], cur_x + cur_w - (last[0] + last[1]), blocks.size(), 0.0, 0.0])
	blocks.append([l, r - l])
	cur_w = r - l
	add(1 + (2 if perfect else 0))
	Sound.tone(400 + blocks.size() * 25 + (200 if perfect else 0), 0.06, 2)
	speed = minf(speed + 18.0, 900.0)

func paint() -> void:
	var n = blocks.size()
	var base_y = area.size.y - 40.0
	var shift = maxf(0.0, (n + 1) * BH - (area.size.y - 140.0))
	for i in n:
		var b = blocks[i]
		area.draw_style_box(Games.flat(Color.from_hsv(fmod(i * 0.07, 1.0), 0.6, 0.95), 8), Rect2(b[0], base_y - (i + 1) * BH + shift, b[1], BH - 4))
	for b in debris:
		var yy = base_y - (b[2] + 1) * BH + shift + b[3]
		area.draw_style_box(Games.flat(Color.from_hsv(fmod(b[2] * 0.07, 1.0), 0.6, 0.95, 0.7), 8), Rect2(b[0], yy, b[1], BH - 4))
	if n > 0:
		area.draw_style_box(Games.flat(Color.WHITE, 8), Rect2(cur_x, base_y - (n + 1) * BH + shift, cur_w, BH - 4))
	if fx_t > 0.0:
		area.draw_string(ThemeDB.fallback_font, Vector2(0, 80.0 - (1.0 - fx_t) * 30.0), "PERFECT!", HORIZONTAL_ALIGNMENT_CENTER, area.size.x, 64, Color(1, 0.9, 0.2, fx_t))
