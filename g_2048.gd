extends "res://base.gd"
var g = []
var score = 0
var best = 0
var start = null
var anim_list = []
var anim_t = 1.0
var pop_t = 1.0
var merged = {}
var spawn_set = {}
var check_pending = false

func build() -> void:
	for i in 16:
		g.append(0)
	var c = ConfigFile.new()
	if c.load("user://b2048.cfg") == OK:
		best = int(c.get_value("s", "best", 0))
	spawn()
	spawn()
	pop_t = 0.0
	canvas(paint, inp)
	status()

func status() -> void:
	say("🔢 %s: %d   %s: %d" % [Games.L("النتيجة", "Score"), score, Games.L("الأفضل", "Best"), best])

func spawn() -> void:
	var free = []
	for i in 16:
		if g[i] == 0:
			free.append(i)
	if free.size() > 0:
		var k = free.pick_random()
		g[k] = 4 if randf() < 0.1 else 2
		spawn_set[k] = true

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
	var items = []
	for j in 4:
		if line[j] != 0:
			items.append([line[j], j])
	var out = []
	var srcs = []
	var mg = []
	var i = 0
	while i < items.size():
		if i + 1 < items.size() and items[i][0] == items[i + 1][0]:
			out.append(items[i][0] * 2)
			srcs.append([items[i][1], items[i + 1][1]])
			mg.append(true)
			score += items[i][0] * 2
			i += 2
		else:
			out.append(items[i][0])
			srcs.append([items[i][1]])
			mg.append(false)
			i += 1
	while out.size() < 4:
		out.append(0)
		srcs.append([])
		mg.append(false)
	return [out, srcs, mg]

func move(d: int) -> void:
	if over:
		return
	anim_t = 1.0
	var old = g.duplicate()
	var changed = false
	var list = []
	var mg = {}
	for k in 4:
		var ix = idxs(d, k)
		var line = []
		for i in ix:
			line.append(g[i])
		var res = slide(line)
		for j in 4:
			var to_i = ix[j]
			var val = res[0][j]
			if g[to_i] != val:
				changed = true
			g[to_i] = val
			if val != 0:
				for sidx in res[1][j]:
					list.append([ix[sidx], to_i, old[ix[sidx]]])
				if res[2][j]:
					mg[to_i] = true
	if not changed:
		return
	spawn_set = {}
	spawn()
	anim_list = list
	merged = mg
	anim_t = 0.0
	pop_t = 0.0
	check_pending = true
	Sound.tone(400, 0.06, 2)
	if score > best:
		best = score
		var c = ConfigFile.new()
		c.set_value("s", "best", best)
		c.save("user://b2048.cfg")
	status()
	body.queue_redraw()

func stuck() -> bool:
	for i in 16:
		if g[i] == 0:
			return false
		if i % 4 < 3 and g[i] == g[i + 1]:
			return false
		if i < 12 and g[i] == g[i + 4]:
			return false
	return true

func _process(d: float) -> void:
	super._process(d)
	if anim_t < 1.0:
		anim_t = minf(1.0, anim_t + d / 0.1)
		body.queue_redraw()
	elif pop_t < 1.0:
		pop_t = minf(1.0, pop_t + d / 0.16)
		body.queue_redraw()
	if anim_t >= 1.0 and check_pending:
		check_pending = false
		if stuck():
			Sound.lose()
			finish("💥 %s — %d" % [Games.L("انتهت", "Game over"), score], Color("ff7675"))

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

func draw_tile(p: Vector2, c: float, v: int, sc: float) -> void:
	var f = ThemeDB.fallback_font
	var size = Vector2(c - 12.0, c - 12.0) * sc
	var ctr = p + Vector2(c, c) / 2.0
	var r = Rect2(ctr - size / 2.0, size)
	body.draw_style_box(Games.flat(tile_color(v), 16), r)
	var fs = int((56 if v < 100 else (46 if v < 1000 else 36)) * sc)
	if fs > 8:
		body.draw_string(f, Vector2(r.position.x, ctr.y + fs * 0.35), str(v), HORIZONTAL_ALIGNMENT_CENTER, r.size.x, fs, Color.WHITE)

func paint() -> void:
	var s = minf(body.size.x - 40.0, body.size.y - 60.0)
	var ox = (body.size.x - s) / 2.0
	var oy = (body.size.y - s) / 2.0
	var c = s / 4.0
	body.draw_style_box(Games.flat(Color("3a2f6b"), 26), Rect2(ox, oy, s, s))
	for i in 16:
		var r = Rect2(ox + (i % 4) * c + 6, oy + (i / 4) * c + 6, c - 12, c - 12)
		body.draw_style_box(Games.flat(Color(1, 1, 1, 0.08), 16), r)
	if anim_t < 1.0:
		var k = 1.0 - pow(1.0 - anim_t, 3.0)
		for a in anim_list:
			var p0 = Vector2(ox + (a[0] % 4) * c, oy + (a[0] / 4) * c)
			var p1 = Vector2(ox + (a[1] % 4) * c, oy + (a[1] / 4) * c)
			draw_tile(p0.lerp(p1, k), c, a[2], 1.0)
	else:
		for i in 16:
			if g[i] > 0:
				var sc = 1.0
				if spawn_set.has(i) and pop_t < 1.0:
					sc = pop_t
				elif merged.has(i) and pop_t < 1.0:
					sc = 1.0 + 0.18 * sin(pop_t * PI)
				draw_tile(Vector2(ox + (i % 4) * c, oy + (i / 4) * c), c, g[i], sc)
