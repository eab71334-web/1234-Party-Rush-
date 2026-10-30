extends "res://quiz.gd"
var parts = []
var target_art: Control

func mk(parent: Control) -> Control:
	var a = Control.new()
	a.set_script(load("res://art.gd"))
	a.set("kind", "sym")
	a.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(a)
	return a

func setup() -> void:
	super.setup()
	target_art = Control.new()
	target_art.set_script(load("res://art.gd"))
	target_art.set("kind", "sym")
	target_art.set_anchors_preset(PRESET_TOP_WIDE)
	target_art.offset_top = 60
	target_art.offset_bottom = 400
	area.add_child(target_art)
	for b in optb:
		parts.append(mk(b))
	next_q()

func hint_text() -> String:
	return Games.L("اضغط نفس الشكل", "Tap the same shape")

func next_q() -> void:
	if parts.is_empty():
		return
	var t = rng.randi() % 10
	var ids = [t]
	while ids.size() < 4:
		var v = rng.randi() % 10
		if not ids.has(v):
			ids.append(v)
	var pos = rng.randi() % 4
	var others = ids.slice(1)
	target_art.set("idx", t)
	target_art.queue_redraw()
	for i in 4:
		var v = t if i == pos else others.pop_back()
		parts[i].set("idx", v)
		parts[i].queue_redraw()
		Games.tint(optb[i], Color("f5f6fa"))
	ans = pos
