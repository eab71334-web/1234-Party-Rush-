extends "res://race.gd"
var blocks = []
var cur_x = 0.0
var cur_w = 300.0
var dirn = 1.0
var speed = 380.0
const BH = 56.0

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.draw.connect(paint)
	area.gui_input.connect(inp)
	blocks.append([area.size.x / 2.0 - 150.0 if area.size.x > 0 else 210.0, 300.0])
	cur_w = 300.0

func hint_text() -> String:
	return Games.L("اضغط لإسقاط الكتلة بدقة", "Tap to drop the block precisely")

func tick(d: float) -> void:
	cur_x += dirn * speed * d
	if cur_x < 0.0:
		cur_x = 0.0
		dirn = 1.0
	if cur_x + cur_w > area.size.x:
		cur_x = area.size.x - cur_w
		dirn = -1.0
	area.queue_redraw()

func inp(e: InputEvent) -> void:
	if not running or not (e is InputEventMouseButton and e.pressed):
		return
	var last = blocks.back()
	var l = maxf(cur_x, last[0])
	var r = minf(cur_x + cur_w, last[0] + last[1])
	if r - l < 12.0:
		Sound.lose()
		end_round()
		return
	blocks.append([l, r - l])
	cur_w = r - l
	add(1 + (2 if absf(cur_x - last[0]) < 8.0 else 0))
	Sound.tone(400 + blocks.size() * 25, 0.06, 2)
	speed += 18.0

func paint() -> void:
	var n = blocks.size()
	var base_y = area.size.y - 40.0
	var shift = maxf(0.0, (n + 1) * BH - (area.size.y - 140.0))
	for i in n:
		var b = blocks[i]
		area.draw_style_box(Games.flat(Color.from_hsv(fmod(i * 0.07, 1.0), 0.6, 0.95), 8), Rect2(b[0], base_y - (i + 1) * BH + shift, b[1], BH - 4))
	area.draw_style_box(Games.flat(Color.WHITE, 8), Rect2(cur_x, base_y - (n + 1) * BH + shift, cur_w, BH - 4))
