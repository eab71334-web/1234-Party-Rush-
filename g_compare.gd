extends "res://quiz.gd"

func setup() -> void:
	NOPTS = 2
	super.setup()

func hint_text() -> String:
	return Games.L("اضغط الرقم الأكبر", "Tap the bigger number")

func next_q() -> void:
	var a = rng.randi_range(10, 99)
	var b = rng.randi_range(10, 99)
	if a == b:
		b += 1
	prompt.text = "?"
	ans = 0 if a > b else 1
	set_opt(0, str(a), col(0))
	set_opt(1, str(b), col(1))
