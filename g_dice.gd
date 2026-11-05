extends "res://base.gd"
const GOAL = 50
var pos = []
var bars = []
var labs = []
var die: Control
var rolling = false
var rbtn: Button

func build() -> void:
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 22)
	body.add_child(v)
	for i in players:
		pos.append(0)
		var pb = ProgressBar.new()
		pb.max_value = GOAL
		pb.show_percentage = false
		pb.custom_minimum_size = Vector2(0, 70)
		pb.add_theme_stylebox_override("fill", Games.style(col(i), 20))
		pb.add_theme_stylebox_override("background", Games.style(Color(1, 1, 1, 0.12), 20))
		var l = big_label("%s  0/%d" % [Games.PN[i], GOAL], 34)
		l.set_anchors_preset(PRESET_FULL_RECT)
		pb.add_child(l)
		v.add_child(pb)
		bars.append(pb)
		labs.append(l)
	spacer(v)
	die = Control.new()
	die.set_script(load("res://art.gd"))
	die.set("kind", "die")
	die.set("idx", 5)
	die.custom_minimum_size = Vector2(0, 260)
	v.add_child(die)
	spacer(v)
	rbtn = Games.btn(Games.L("ارمِ النرد", "Roll the die"), Color("f7b731"), 150, 52)
	rbtn.pressed.connect(roll)
	v.add_child(rbtn)
	show_turn()

func roll() -> void:
	if over or rolling:
		return
	rolling = true
	rbtn.disabled = true
	var n = 1
	for k in 9:
		n = randi_range(1, 6)
		die.set("idx", n)
		die.queue_redraw()
		Sound.tone(300 + k * 40, 0.05, 3, -14.0)
		if not await wait(0.07):
			return
	die.pivot_offset = die.size / 2.0
	die.scale = Vector2(1.25, 1.25)
	create_tween().tween_property(die, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pos[turn] = mini(pos[turn] + n, GOAL)
	labs[turn].text = "%s  %d/%d" % [Games.PN[turn], pos[turn], GOAL]
	create_tween().tween_property(bars[turn], "value", float(pos[turn]), 0.4)
	Sound.tone(500 + n * 60, 0.15, 2)
	if pos[turn] >= GOAL:
		finish("🏆 فاز " + Games.PN[turn], col(turn))
		return
	if n == 6:
		say("طلع 6! ارمِ مرة ثانية", col(turn))
	else:
		next_turn()
	rolling = false
	rbtn.disabled = false
