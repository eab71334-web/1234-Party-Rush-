extends "res://race.gd"
var seq = []
var idx_p = 0
var accept = false
var pads = []

func setup() -> void:
	time_left = 45.0
	var g = GridContainer.new()
	g.columns = 2
	g.set_anchors_preset(PRESET_CENTER)
	g.grow_horizontal = Control.GROW_DIRECTION_BOTH
	g.grow_vertical = Control.GROW_DIRECTION_BOTH
	g.add_theme_constant_override("h_separation", 20)
	g.add_theme_constant_override("v_separation", 20)
	area.add_child(g)
	var sz = minf(get_viewport_rect().size.x / 2.0 - 60.0, 300.0)
	for i in 4:
		var b = Games.btn("", col(i), 300, 40)
		b.custom_minimum_size = Vector2(sz, sz)
		b.modulate = Color(0.5, 0.5, 0.5)
		b.button_down.connect(tap.bind(i))
		g.add_child(b)
		pads.append(b)

func hint_text() -> String:
	return Games.L("احفظ التسلسل وكرره", "Memorize and repeat the sequence")

func begin() -> void:
	next_round()

func dur() -> float:
	return maxf(0.18, 0.35 - seq.size() * 0.012)

func flash(i: int, t: float) -> void:
	var b = pads[i]
	b.modulate = Color.WHITE
	b.pivot_offset = b.size / 2.0
	b.scale = Vector2(1.06, 1.06)
	Sound.tone(260 + i * 100, t, 0, -4.0)
	if not await wait(t):
		return
	b.modulate = Color(0.5, 0.5, 0.5)
	b.scale = Vector2.ONE

func replay() -> void:
	for s in seq:
		if not running:
			return
		await flash(s, dur())
		if not await wait(0.1):
			return

func next_round() -> void:
	accept = false
	seq.append(rng.randi() % 4)
	if not await wait(0.5):
		return
	await replay()
	accept = true
	idx_p = 0

func tap(i: int) -> void:
	if not accept or not running:
		return
	flash(i, 0.15)
	if seq[idx_p] == i:
		idx_p += 1
		if idx_p == seq.size():
			accept = false
			add(seq.size())
			next_round()
	else:
		accept = false
		add(-1)
		Sound.lose()
		idx_p = 0
		for b in pads:
			b.modulate = Color(1.0, 0.45, 0.45)
		if not await wait(0.5):
			return
		for b in pads:
			b.modulate = Color(0.5, 0.5, 0.5)
		await replay()
		accept = true
