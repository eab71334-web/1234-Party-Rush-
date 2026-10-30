extends "res://base.gd"
const GOAL = 50
var pos = []
var bars = []
var die: Control
var rolling = false

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
		var l = big_label(Games.PN[i], 34)
		l.set_anchors_preset(PRESET_FULL_RECT)
		pb.add_child(l)
		v.add_child(pb)
		bars.append(pb)
	spacer(v)
	die = Control.new()
	die.set_script(load("res://art.gd"))
	die.set("kind", "die")
	die.set("idx", 5)
	die.custom_minimum_size = Vector2(0, 260)
	v.add_child(die)
	spacer(v)
	var b = Games.btn("ارمِ النرد", Color("f7b731"), 150, 52)
	b.pressed.connect(roll)
	v.add_child(b)
	show_turn()

func roll() -> void:
	if over or rolling:
		return
	rolling = true
	var n = 1
	for k in 9:
		n = randi_range(1, 6)
		die.set("idx", n)
		die.queue_redraw()
		Sound.tone(300 + k * 40, 0.05, 3, -14.0)
		if not await wait(0.07):
			return
	pos[turn] += n
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
