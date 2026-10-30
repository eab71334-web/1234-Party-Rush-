extends "res://base.gd"
var p = 0.5
var tb = []

func build() -> void:
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 8)
	body.add_child(v)
	for i in 2:
		var b = Games.btn(Games.PN[i] + "\nاضغط بسرعة!", col(i), 100, 52)
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.button_down.connect(pull.bind(i))
		v.add_child(b)
		tb.append(b)
	say("🪢 شد الحبل!")

func pull(i: int) -> void:
	if over:
		return
	p += 0.035 if i == 0 else -0.035
	Sound.tone(300 + i * 150, 0.04, 2, -10.0)
	tb[0].size_flags_stretch_ratio = maxf(p, 0.02)
	tb[1].size_flags_stretch_ratio = maxf(1.0 - p, 0.02)
	if p >= 0.94:
		finish("🏆 فاز " + Games.PN[0], col(0))
	elif p <= 0.06:
		finish("🏆 فاز " + Games.PN[1], col(1))
