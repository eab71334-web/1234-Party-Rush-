extends "res://quiz.gd"

func hint_text() -> String:
	return Games.L("اضغط لون الحبر مو الكلمة", "Tap the INK color, not the word")

func next_q() -> void:
	var a = rng.randi() % 4
	var b = rng.randi() % 4
	prompt.text = Games.L(["أحمر", "أزرق", "أخضر", "أصفر"][a], ["Red", "Blue", "Green", "Yellow"][a])
	prompt.add_theme_color_override("font_color", Games.PC[b])
	ans = b
	for i in 4:
		set_opt(i, "", Games.PC[i])
