extends "res://race.gd"
var grid: GridContainer
var nxt = 1
var N = 9

func setup() -> void:
	grid = GridContainer.new()
	grid.columns = 3
	grid.set_anchors_preset(PRESET_CENTER)
	grid.grow_horizontal = Control.GROW_DIRECTION_BOTH
	grid.grow_vertical = Control.GROW_DIRECTION_BOTH
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	area.add_child(grid)

func hint_text() -> String:
	return Games.L("اضغط الأرقام بالترتيب من 1", "Tap numbers in order from 1")

func begin() -> void:
	rebuild()

func rebuild() -> void:
	for c in grid.get_children():
		c.queue_free()
	nxt = 1
	var nums = []
	for i in N:
		nums.append(i + 1)
	rshuffle(nums)
	var sz = minf(area.size.x - 40.0, area.size.y - 80.0) / 3.0 - 12.0
	for v in nums:
		var b = Games.btn(str(v), Games.PC[v % 4], 60, 70)
		b.custom_minimum_size = Vector2(sz, sz)
		b.button_down.connect(tap.bind(v, b))
		grid.add_child(b)

func tap(v: int, b: Button) -> void:
	if not running:
		return
	if v == nxt:
		add(1)
		Sound.tone(500 + v * 60, 0.06, 2)
		b.disabled = true
		b.modulate.a = 0.35
		nxt += 1
		if nxt > N:
			add(3)
			rebuild()
	else:
		add(-1)
		Sound.tone(180, 0.1, 1)
