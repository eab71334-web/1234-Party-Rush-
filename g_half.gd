extends "res://quiz.gd"

func hint_text() -> String:
	return Games.L("اختر نصف الرقم", "Pick half of the number")

func next_q() -> void:
	var n = rng.randi_range(4, 60) * 2
	prompt.text = "½ × %d" % n
	num_opts(n / 2, 8)
