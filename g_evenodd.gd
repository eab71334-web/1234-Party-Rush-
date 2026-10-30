extends "res://quiz.gd"

func setup() -> void:
	NOPTS = 2
	super.setup()

func hint_text() -> String:
	return Games.L("زوجي أو فردي؟", "Even or odd?")

func next_q() -> void:
	var n = rng.randi_range(1, 99)
	prompt.text = str(n)
	ans = 0 if n % 2 == 0 else 1
	set_opt(0, Games.L("زوجي", "Even"), col(1))
	set_opt(1, Games.L("فردي", "Odd"), col(0))
