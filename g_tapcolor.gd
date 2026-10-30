extends "res://quiz.gd"

func hint_text() -> String:
	return Games.L("اضغط اللون المكتوب", "Tap the color named")

func next_q() -> void:
	var a = rng.randi() % 4
	prompt.text = Games.L(["أحمر", "أزرق", "أخضر", "أصفر"][a], ["Red", "Blue", "Green", "Yellow"][a])
	prompt.add_theme_color_override("font_color", Color.WHITE)
	var ord = [0, 1, 2, 3]
	ord.shuffle()
	ans = ord.find(a)
	for i in 4:
		set_opt(i, "", Games.PC[ord[i]])
