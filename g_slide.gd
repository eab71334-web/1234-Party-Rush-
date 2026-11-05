extends "res://base.gd"
var t = []
var moves = 0
var cell = 150.0
var ox = 0.0
var oy = 0.0
var slid = {}
var slide_t = 1.0
var secs = 0.0
var last_sec = -1

func build() -> void:
	for i in 16:
		t.append((i + 1) % 16)
	var e = 15
	var prev = -1
	for k in 300:
		var r = e / 4
		var c = e % 4
		var nb = []
		if r > 0:
			nb.append(e - 4)
		if r < 3:
			nb.append(e + 4)
		if c > 0:
			nb.append(e - 1)
		if c < 3:
			nb.append(e + 1)
		nb.erase(prev)
		var m = nb.pick_random()
		t[e] = t[m]
		t[m] = 0
		prev = e
		e = m
	if solved():
		t[14] = t[15]
		t[15] = 0
	canvas(paint, inp)
	status_text()

func solved() -> bool:
	for k in 15:
		if t[k] != k + 1:
			return false
	return t[15] == 0

func status_text() -> void:
	say("🧩 الحركات: %d   |   %d:%02d" % [moves, int(secs) / 60, int(secs) % 60])

func _process(d: float) -> void:
	super._process(d)
	if over:
		return
	secs += d
	if int(secs) != last_sec:
		last_sec = int(secs)
		status_text()
	if slide_t < 1.0:
		slide_t = minf(1.0, slide_t + d / 0.14)
		body.queue_redraw()

func inp(e: InputEvent) -> void:
	if over or not (e is InputEventMouseButton and e.pressed):
		return
	var c = floori((e.position.x - ox) / cell)
	var r = floori((e.position.y - oy) / cell)
	if c < 0 or r < 0 or c > 3 or r > 3:
		return
	slide(r * 4 + c)

func slide(i: int) -> void:
	var e = t.find(0)
	if i == e:
		return
	var er = e / 4
	var ec = e % 4
	var r = i / 4
	var c = i % 4
	if r != er and c != ec:
		Sound.tone(150, 0.08, 1)
		return
	var step = signi(r - er) * 4 + signi(c - ec)
	slid = {}
	var k = e
	while k != i:
		var nk = k + step
		t[k] = t[nk]
		slid[k] = nk
		k = nk
	t[i] = 0
	slide_t = 0.0
	moves += 1
	Sound.tone(500, 0.05, 2)
	status_text()
	body.queue_redraw()
	if solved():
		slid = {}
		finish("🎉 حليتها في %d حركة" % moves)

func paint() -> void:
	cell = minf((body.size.x - 40.0) / 4.0, (body.size.y - 60.0) / 4.0)
	ox = (body.size.x - cell * 4) / 2.0
	oy = (body.size.y - cell * 4) / 2.0
	var f = ThemeDB.fallback_font
	body.draw_style_box(Games.style(Color("2b2257"), 26, 0), Rect2(ox - 12, oy - 12, cell * 4 + 24, cell * 4 + 24))
	var ease_k = 1.0 - pow(1.0 - slide_t, 3.0)
	for i in 16:
		if t[i] == 0:
			continue
		var p = Vector2(ox + (i % 4) * cell, oy + (i / 4) * cell)
		if slid.has(i):
			var o = slid[i]
			var po = Vector2(ox + (o % 4) * cell, oy + (o / 4) * cell)
			p = po.lerp(p, ease_k)
		var right = (t[i] == i + 1)
		var base = Color("3ddc97") if right else Color("ff6b81").lerp(Color("ffa502"), t[i] / 15.0)
		var rc = Rect2(p + Vector2(5, 5), Vector2(cell - 10, cell - 10))
		body.draw_style_box(Games.style(base, int(cell * 0.14), 6), rc)
		var fs = int(cell * 0.42)
		body.draw_string(f, Vector2(rc.position.x, rc.position.y + rc.size.y / 2.0 + fs * 0.33), str(t[i]), HORIZONTAL_ALIGNMENT_CENTER, rc.size.x, fs, Color.WHITE)
