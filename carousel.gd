extends Control
signal chosen(game)
var items = []
var cards = []
var arts = []
var pos = 0.0
var target = 0.0
var dragging = false
var moved = 0.0
var last_x = 0.0
var vel = 0.0
var near = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = false

func lbl(t: String, p: Vector2, sz: Vector2, fs: int) -> Label:
	var l = Label.new()
	l.text = Games.tx(t)
	l.position = p
	l.size = sz
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.45))
	l.add_theme_constant_override("outline_size", 10)
	return l

func players_text(g: Array) -> String:
	var a = g[3]
	var b = g[4]
	if a == b:
		if a == 1:
			return Games.L("لاعب واحد", "1 player")
		return Games.L("%d لاعبين" % a, "%d players" % a)
	return Games.L("%d - %d لاعبين" % [a, b], "%d - %d players" % [a, b])

func make_card(g: Array) -> Control:
	var c = Control.new()
	c.size = Vector2(500, 680)
	c.pivot_offset = Vector2(250, 340)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p = Panel.new()
	p.size = Vector2(500, 680)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", Games.style(Color(g[5]), 46, 16))
	c.add_child(p)
	var w = Panel.new()
	w.position = Vector2(26, 26)
	w.size = Vector2(448, 448)
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	w.add_theme_stylebox_override("panel", Games.flat(Color(g[6]), 36))
	c.add_child(w)
	var a = Control.new()
	a.set_script(load("res://art.gd"))
	a.set("kind", g[0])
	a.set("idx", g[9])
	a.position = Vector2(26, 26)
	a.size = Vector2(448, 448)
	c.add_child(a)
	c.add_child(lbl(Games.L(g[1], g[7]), Vector2(14, 484), Vector2(472, 100), 54))
	var pill = Panel.new()
	pill.position = Vector2(110, 596)
	pill.size = Vector2(280, 56)
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_theme_stylebox_override("panel", Games.flat(Color(0, 0, 0, 0.3), 28))
	c.add_child(pill)
	c.add_child(lbl(players_text(g), Vector2(110, 596), Vector2(280, 56), 30))
	arts.append(a)
	return c

func setup(list: Array) -> void:
	items = list
	for g in list:
		var c = make_card(g)
		add_child(c)
		cards.append(c)

func k() -> float:
	return minf(1.0, size.y / 740.0)

func _process(d: float) -> void:
	if cards.is_empty():
		return
	if not dragging:
		pos = lerpf(pos, target, 1.0 - exp(-d * 12.0))
	var kk = k()
	var ni = clampi(roundi(pos), 0, cards.size() - 1)
	if ni != near:
		if near >= 0:
			arts[near].set("animate", false)
		arts[ni].set("animate", true)
		near = ni
	for i in cards.size():
		var off = i - pos
		var a = absf(off)
		var c = cards[i]
		c.visible = a < 1.9
		if not c.visible:
			continue
		var s = lerpf(1.0, 0.7, minf(a, 1.0)) * kk
		c.scale = Vector2(s, s)
		c.rotation = off * 0.05
		c.position = Vector2(size.x / 2.0 + off * 400.0 * kk - 250.0, size.y / 2.0 - 340.0 + minf(a, 1.0) * 30.0)
		c.modulate.a = lerpf(1.0, 0.5, minf(a, 1.0))
		c.z_index = 10 - int(a * 3.0)
	queue_redraw()

func _draw() -> void:
	var n = items.size()
	var gap = minf(26.0, (size.x - 80.0) / maxf(n, 1))
	for i in n:
		var x = size.x / 2.0 + (i - (n - 1) / 2.0) * gap
		var near_f = clampf(1.0 - absf(i - pos), 0.0, 1.0)
		draw_circle(Vector2(x, size.y - 14.0), 5.0 + 4.0 * near_f, Color(1, 1, 1, 0.35 + 0.65 * near_f))

func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			dragging = true
			moved = 0.0
			vel = 0.0
			last_x = e.position.x
		elif dragging:
			dragging = false
			if moved < 22.0:
				tap(e.position.x)
			else:
				target = float(clampi(roundi(pos + vel * 6.0), 0, items.size() - 1))
	elif e is InputEventMouseMotion and dragging:
		var dx = e.position.x - last_x
		last_x = e.position.x
		moved += absf(dx)
		var step = -dx / (400.0 * k())
		vel = lerpf(vel, step, 0.4)
		pos = clampf(pos + step, -0.3, items.size() - 0.7)

func tap(x: float) -> void:
	var off = (x - size.x / 2.0) / (400.0 * k())
	var i = clampi(roundi(pos + off), 0, items.size() - 1)
	if i == roundi(target) and absf(off) < 0.6:
		Sound.tone(900, 0.12, 2)
		chosen.emit(items[i])
	else:
		target = float(i)
		Sound.tone(600, 0.05, 2)
