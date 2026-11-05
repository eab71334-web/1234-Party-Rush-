extends "res://race.gd"
var arrow: Control
var dir = 0
var start = null

func setup() -> void:
	area.mouse_filter = Control.MOUSE_FILTER_STOP
	area.gui_input.connect(inp)
	arrow = Control.new()
	arrow.set_script(load("res://art.gd"))
	arrow.set("kind", "arrow")
	arrow.set("col", Color("48dbfb"))
	arrow.set_anchors_preset(PRESET_FULL_RECT)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow.resized.connect(func(): arrow.pivot_offset = arrow.size / 2.0)
	area.add_child(arrow)
	pick_dir()

func hint_text() -> String:
	return Games.L("اسحب في اتجاه السهم", "Swipe in the arrow's direction")

func pick_dir() -> void:
	dir = rng.randi() % 4
	arrow.set("idx", dir)
	arrow.queue_redraw()
	arrow.scale = Vector2(0.7, 0.7)
	create_tween().tween_property(arrow, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func resolve(d: Vector2) -> void:
	var got = 0
	if absf(d.x) > absf(d.y):
		got = 1 if d.x > 0 else 3
	else:
		got = 2 if d.y > 0 else 0
	if got == dir:
		add(1)
		Sound.tone(800, 0.05, 2)
		arrow.modulate = Color("7dffb0")
	else:
		add(-1)
		Sound.tone(180, 0.1, 1)
		arrow.modulate = Color("ff6b6b")
	create_tween().tween_property(arrow, "modulate", Color.WHITE, 0.25)
	pick_dir()

func inp(e: InputEvent) -> void:
	if not running:
		return
	if e is InputEventMouseButton:
		if e.pressed:
			start = e.position
		elif start != null:
			var d = e.position - start
			start = null
			if d.length() > 60.0:
				resolve(d)
	elif e is InputEventMouseMotion and start != null:
		var d2 = e.position - start
		if d2.length() > 60.0:
			start = null
			resolve(d2)
