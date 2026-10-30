extends "res://base.gd"
var g = []
var score = 0
var start = null

func build() -> void:
	for i in 16:
		g.append(0)
	spawn()
	spawn()
	canvas(paint, inp)
	say("🔢 اسحب لدمج الأرقام")

func spawn() -> void:
	var free = []
	for i in 16:
		if g[i] == 0:
			free.append(i)
	if free.size() > 0:
		g[free.pick_random()] = 4 if randf() < 0.1 else 2

func idxs(d: int, k: int) -> Array:
	var a = []
	for j in 4:
		match d:
			0:
				a.append(k * 4 + j)
			1:
				a.append(k * 4 + 3 - j)
			2:
				a.append(j * 4 + k)
			3:
				a.append((3 - j) * 4 + k)
	return a

func slide(line: Array) -> Array:
	var v = line.filter(func(x): return x != 0)
	var out = []
	var i = 0
	while i < v.size():
		if i + 1 < v.size() and v[i] == v[i + 1]:
			out.append(v[i] * 2)
			score += v[i] * 2
			i += 2
		else:
			out.append(v[i])
			i += 1
	while out.size() < 4:
		out.append(0)
	return out

func move(d: int) -> void:
	if over:
		return
	var changed = false
	for k in 4:
		var ix = idxs(d, k)
		var line = []
		for i in ix:
			line.append(g[i])
		var res = slide(line)
		for j in 4:
			if g[ix[j]] != res[j]:
				changed = true
			g[ix[j]] = res[j]
	if changed:
		Sound.tone(400, 0.06, 2)
		spawn()
		say("🔢 النتيجة: %d" % score)
		body.queue_redraw()
		if stuck():
			finish("💥 انتهت — %d" % score, Color("ff7675"))

func stuck() -> bool:
	for i in 16:
		if g[i] == 0:
			return false
		if i % 4 < 3 and g[i] == g[i + 1]:
			return false
		if i < 12 and g[i] == g[i + 4]:
			return false
	return true

func inp(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.pressed:
			start = e.position
		elif start != null:
			var d = e.position - start
			start = null
			if d.length() > 50.0:
				if absf(d.x) > absf(d.y):
					move(1 if d.x > 0 else 0)
				else:
					move(3 if d.y > 0 else 2)

func tile_color(v: int) -> Color:
	if v == 0:
		return Color(1, 1, 1, 0.08)
	return Color.from_hsv(fmod(log(float(v)) / log(2.0) * 0.09, 1.0), 0.6, 0.95)

func paint() -> void:
	var f = ThemeDB.fallback_font
	var s = minf(body.size.x - 40.0, body.size.y - 60.0)
	var ox = (body.size.x - s) / 2.0
	var oy = (body.size.y - s) / 2.0
	body.draw_style_box(Games.flat(Color("3a2f6b"), 26), Rect2(ox, oy, s, s))
	var c = s / 4.0
	for i in 16:
		var r = Rect2(ox + (i % 4) * c + 6, oy + (i / 4) * c + 6, c - 12, c - 12)
		var v = g[i]
		body.draw_style_box(Games.flat(tile_color(v), 16), r)
		if v > 0:
			var fs = 56 if v < 100 else (46 if v < 1000 else 36)
			body.draw_string(f, Vector2(r.position.x, r.position.y + r.size.y / 2.0 + fs * 0.35), str(v), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, fs, Color.WHITE)
