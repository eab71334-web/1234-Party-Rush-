extends "res://base.gd"
const GOAL = 25
var score = []
var btns = []
var t0 = 0

func build() -> void:
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 14)
	body.add_child(v)
	for i in players:
		score.append(0)
		var b = Games.btn("0", col(i), 100, 110)
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.button_down.connect(tap.bind(i))
		v.add_child(b)
		btns.append(b)
	say("⚡ اضغط بسرعة! الهدف %d" % GOAL)

func tap(i: int) -> void:
	if over:
		return
	if t0 == 0:
		t0 = Time.get_ticks_msec()
	score[i] += 1
	btns[i].text = str(score[i])
	Sound.tone(400 + score[i] * 15, 0.05, 2)
	if score[i] >= GOAL:
		var secs = (Time.get_ticks_msec() - t0) / 1000.0
		if players == 1:
			finish("⏱ خلصت في %.1f ثانية" % secs)
		else:
			finish("🏆 فاز " + Games.PN[i], col(i))
