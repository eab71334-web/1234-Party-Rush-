extends "res://base.gd"
var scores = []
var turn_total = 0
var info: Label
var die: Control
var rb: Button
var hb: Button
const GOAL = 50

func build() -> void:
	for i in players:
		scores.append(0)
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 16)
	body.add_child(v)
	info = big_label("", 40)
	info.custom_minimum_size = Vector2(0, 140)
	v.add_child(info)
	die = Control.new()
	die.set_script(load("res://art.gd"))
	die.set("kind", "die")
	die.set("idx", 1)
	die.custom_minimum_size = Vector2(0, 260)
	v.add_child(die)
	spacer(v)
	var hb2 = HBoxContainer.new()
	hb2.add_theme_constant_override("separation", 16)
	v.add_child(hb2)
	rb = Games.btn(Games.L("ارمِ", "ROLL"), Color("f39c12"), 150, 52)
	rb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rb.button_down.connect(roll_pressed)
	hb2.add_child(rb)
	hb = Games.btn(Games.L("احتفظ", "HOLD"), Color("27ae60"), 150, 52)
	hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.button_down.connect(hold_pressed)
	hb2.add_child(hb)
	refresh()
	show_turn()

func refresh() -> void:
	var s = ""
	for i in players:
		s += "%s: %d     " % [Games.PN[i], scores[i]]
	info.text = s + "\n" + Games.L("رصيد الدور: ", "Turn total: ") + str(turn_total)

func roll_pressed() -> void:
	if over or not my_turn():
		return
	act({"t": "r"})

func hold_pressed() -> void:
	if over or not my_turn() or turn_total == 0:
		return
	act({"t": "h"})

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	if d.get("t", "") == "r":
		var v = rng.randi_range(1, 6)
		die.set("idx", v)
		die.queue_redraw()
		Sound.tone(300 + v * 50, 0.1, 3)
		if v == 1:
			turn_total = 0
			Sound.lose()
			refresh()
			next_turn()
			return
		turn_total += v
	else:
		scores[seat] += turn_total
		turn_total = 0
		Sound.tone(900, 0.15, 2)
		if scores[seat] >= GOAL:
			refresh()
			finish("فاز " + Games.PN[seat], col(seat))
			return
		refresh()
		next_turn()
		return
	refresh()
