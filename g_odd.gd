extends "res://race.gd"
var grid: GridContainer
var n = 2
var streak = 0

func setup() -> void:
	grid = GridContainer.new()
	grid.set_anchors_preset(PRESET_CENTER)
	grid.grow_horizontal = Control.GROW_DIRECTION_BOTH
	grid.grow_vertical = Control.GROW_DIRECTION_BOTH
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	area.add_child(grid)

func hint_text() -> String:
	return Games.L("اضغط المربع المختلف", "Tap the different tile")

func begin() -> void:
	rebuild()

func rebuild() -> void:
	for c in grid.get_children():
		grid.remove_child(c)
		c.queue_free()
	grid.columns = n
	var hue = rng.randf()
	var base = Color.from_hsv(hue, 0.6, 0.9)
	var diff = maxf(0.06, 0.24 - streak * 0.012)
	var odd_c = Color.from_hsv(hue, 0.6, 0.9 - diff)
	var odd_i = rng.randi() % (n * n)
	var sz = minf(area.size.x - 40.0, area.size.y - 60.0) / n - 10.0
	for i in n * n:
		var b = Games.btn("", odd_c if i == odd_i else base, 60, 10)
		b.custom_minimum_size = Vector2(sz, sz)
		b.button_down.connect(pick.bind(i == odd_i))
		grid.add_child(b)
		b.pivot_offset = Vector2(sz, sz) / 2.0
		b.scale = Vector2(0.7, 0.7)
		create_tween().tween_property(b, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func pick(ok: bool) -> void:
	if not running:
		return
	if ok:
		add(1)
		Sound.tone(900, 0.06, 2)
		streak += 1
		if streak % 3 == 0 and n < 6:
			n += 1
		rebuild()
	else:
		add(-1)
		Sound.tone(180, 0.12, 1)
		grid.modulate = Color(1, 0.55, 0.55)
		create_tween().tween_property(grid, "modulate", Color.WHITE, 0.3)
