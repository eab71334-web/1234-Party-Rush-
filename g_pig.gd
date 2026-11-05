extends "res://base.gd"
var scores = []
var turn_total = 0
var info: Label
var die: Control
var rb: Button
var hb: Button
var chips = []
var rolling = false
const GOAL = 50

func build() -> void:
	for i in players:
		scores.append(0)
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 16)
	body.add_child(v)
	var cr = HBoxContainer.new()
	cr.add_theme_constant_override("separation", 10)
	v.add_child(cr)
	for i in players:
		var p = PanelContainer.new()
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var l = Label.new()
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 30)
		p.add_child(l)
		cr.add_child(p)
		chips.append([p, l])
	info = big_label("", 52, Color.GOLD)
	info.custom_minimum_size = Vector2(0, 110)
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

func is_busy() -> bool:
	return rolling

func refresh() -> void:
	for i in players:
		chips[i][1].text = "%s\n%d" % [Games.PN[i], scores[i]]
		chips[i][0].add_theme_stylebox_override("panel", Games.style(col(i) if i == turn else col(i).darkened(0.6), 24, 6))
	info.text = Games.L("رصيد الدور: ", "Turn total: ") + str(turn_total)
	var locked = rolling or over or not my_turn()
	rb.disabled = locked
	hb.disabled = locked or turn_total == 0

func roll_pressed() -> void:
	if over or rolling or not my_turn():
		return
	act({"t": "r"})

func hold_pressed() -> void:
	if over or rolling or not my_turn() or turn_total == 0:
		return
	act({"t": "h"})

func on_action(seat: int, d: Dictionary) -> void:
	if over or rolling or seat != turn:
		return
	if d.get("t", "") == "r":
		var v = rng.randi_range(1, 6)
		rolling = true
		refresh()
		for k in 7:
			die.set("idx", randi_range(1, 6))
			die.queue_redraw()
			Sound.tone(300 + k * 30, 0.05, 3, -14.0)
			if not await wait(0.06):
				return
		die.set("idx", v)
		die.queue_redraw()
		die.pivot_offset = die.size / 2.0
		die.scale = Vector2(1.25, 1.25)
		create_tween().tween_property(die, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		Sound.tone(300 + v * 50, 0.1, 3)
		rolling = false
		if v == 1:
			turn_total = 0
			Sound.lose()
			next_turn()
		else:
			turn_total += v
		refresh()
		pump()
	else:
		if turn_total == 0:
			return
		scores[seat] += turn_total
		turn_total = 0
		Sound.tone(900, 0.15, 2)
		if scores[seat] >= GOAL:
			refresh()
			finish("فاز " + Games.PN[seat], col(seat))
			return
		next_turn()
		refresh()
