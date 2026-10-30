extends "res://quiz.gd"
var dots: Control

func setup() -> void:
	super.setup()
	dots = Control.new()
	dots.set_script(load("res://art.gd"))
	dots.set("kind", "dots")
	dots.set("col", Color("ffd166"))
	dots.set_anchors_preset(PRESET_TOP_WIDE)
	dots.offset_top = 40
	dots.offset_bottom = 420
	area.add_child(dots)
	next_q()

func hint_text() -> String:
	return Games.L("كم نقطة؟", "How many dots?")

func next_q() -> void:
	if dots == null:
		return
	var n = rng.randi_range(2, 9)
	dots.set("idx", n)
	dots.queue_redraw()
	num_opts(n, 3)
