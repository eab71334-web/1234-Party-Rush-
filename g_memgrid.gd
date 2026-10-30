extends "res://race.gd"
var tiles = []
var target = []
var k = 3
var accept = false
var found = []

func setup() -> void:
	time_left = 45.0
	var g = GridContainer.new()
	g.columns = 4
	g.set_anchors_preset(PRESET_CENTER)
	g.grow_horizontal = Control.GROW_DIRECTION_BOTH
	g.grow_vertical = Control.GROW_DIRECTION_BOTH
	g.add_theme_constant_override("h_separation", 12)
	g.add_theme_constant_override("v_separation", 12)
	area.add_child(g)
	var sz = minf(get_viewport_rect().size.x - 80.0, 700.0) / 4.0 - 12.0
	for i in 16:
		var b = Games.btn("", Color("3d3d6b"), 100, 10)
		b.custom_minimum_size = Vector2(sz, sz)
		b.button_down.connect(tap.bind(i))
		g.add_child(b)
		tiles.append(b)

func hint_text() -> String:
	return Games.L("احفظ المربعات المضيئة", "Remember the lit tiles")

func begin() -> void:
	new_round()

func new_round() -> void:
	accept = false
	found = []
	target = []
	var all = []
	for i in 16:
		all.append(i)
	rshuffle(all)
	for i in k:
		target.append(all[i])
	for t in tiles:
		Games.tint(t, Color("3d3d6b"))
	if not await wait(0.5):
		return
	for i in target:
		Games.tint(tiles[i], Color("ffd32a"))
	if not await wait(0.9 + k * 0.1):
		return
	for t in tiles:
		Games.tint(t, Color("3d3d6b"))
	accept = true

func tap(i: int) -> void:
	if not accept or not running or found.has(i):
		return
	if target.has(i):
		found.append(i)
		Games.tint(tiles[i], Color("2ed573"))
		Sound.tone(700 + found.size() * 50, 0.06, 2)
		if found.size() == target.size():
			add(k)
			k = mini(k + 1, 10)
			accept = false
			if not await wait(0.4):
				return
			new_round()
	else:
		accept = false
		Games.tint(tiles[i], Color("ff4757"))
		add(-1)
		Sound.lose()
		if not await wait(0.7):
			return
		new_round()
