extends "res://quiz.gd"

func hint_text() -> String:
	return Games.L("اختر الرقم الناقص", "Find the missing number")

func next_q() -> void:
	var a = rng.randi_range(1, 20)
	var d = rng.randi_range(2, 9)
	var hole = rng.randi_range(1, 3)
	var parts = []
	for i in 5:
		parts.append("?" if i == hole else str(a + d * i))
	prompt.text = ", ".join(parts)
	prompt.add_theme_font_size_override("font_size", 90)
	num_opts(a + d * hole, 6)
