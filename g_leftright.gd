extends "res://quiz.gd"
var arrow: Control
var dir = 1

func setup() -> void:
	NOPTS = 2
	super.setup()
	arrow = Control.new()
	arrow.set_script(load("res://art.gd"))
	arrow.set("kind", "arrow")
	arrow.set("col", Color("ffd166"))
	arrow.set_anchors_preset(PRESET_TOP_WIDE)
	arrow.offset_top = 60
	arrow.offset_bottom = 400
	area.add_child(arrow)
	next_q()

func hint_text() -> String:
	return Games.L("اضغط نفس الاتجاه", "Tap the same direction")

func next_q() -> void:
	if arrow == null:
		return
	dir = 1 if rng.randi() % 2 == 0 else 3
	arrow.set("idx", dir)
	arrow.queue_redraw()
	set_opt(0, Games.L("يسار", "Left"), col(1))
	set_opt(1, Games.L("يمين", "Right"), col(0))
	ans = 0 if dir == 3 else 1
	if false:
		ans = 1 - ans
