extends "res://race.gd"

func setup() -> void:
	time_left = 10.0
	var b = Games.btn("TAP!", col(my_seat if online else 0), 400, 120)
	b.set_anchors_preset(PRESET_FULL_RECT)
	b.offset_top = 40
	b.offset_bottom = -40
	b.offset_left = 20
	b.offset_right = -20
	b.button_down.connect(tap)
	area.add_child(b)

func hint_text() -> String:
	return Games.L("اضغط أسرع ما تقدر!", "Tap as fast as you can!")

func tap() -> void:
	if running:
		add(1)
		Sound.tone(500 + (score % 20) * 20, 0.03, 2, -10.0)
