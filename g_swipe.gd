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
	area.add_child(arrow)
	pick_dir()

func hint_text() -> String:
	return Games.L("اسحب في اتجاه السهم", "Swipe in the arrow's direction")

func pick_dir() -> void:
	dir = rng.randi() % 4
	arrow.set("idx", dir)
	arrow.queue_redraw()

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
				var got = 0
				if absf(d.x) > absf(d.y):
					got = 1 if d.x > 0 else 3
				else:
					got = 2 if d.y > 0 else 0
				if got == dir:
					add(1)
					Sound.tone(800, 0.05, 2)
				else:
					add(-1)
					Sound.tone(180, 0.1, 1)
				pick_dir()
