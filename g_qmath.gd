extends "res://quiz.gd"

func hint_text() -> String:
	return Games.L("حل بسرعة!", "Solve fast!")

func next_q() -> void:
	var a = rng.randi_range(2, 12)
	var b = rng.randi_range(2, 12)
	var val = 0
	match rng.randi() % 3:
		0:
			prompt.text = "%d + %d" % [a, b]
			val = a + b
		1:
			prompt.text = "%d - %d" % [a + b, b]
			val = a
		_:
			a = rng.randi_range(2, 9)
			b = rng.randi_range(2, 9)
			prompt.text = "%d × %d" % [a, b]
			val = a * b
	num_opts(val, 7)
