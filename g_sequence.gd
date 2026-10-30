extends "res://quiz.gd"

func hint_text() -> String:
	return Games.L("ما الرقم التالي؟", "What comes next?")

func next_q() -> void:
	var t = rng.randi() % 3
	var seq = []
	var nxt = 0
	if t == 0:
		var a = rng.randi_range(1, 15)
		var d = rng.randi_range(2, 8)
		for i in 4:
			seq.append(a + d * i)
		nxt = a + d * 4
	elif t == 1:
		var a = rng.randi_range(1, 4)
		for i in 4:
			seq.append(a * int(pow(2, i)))
		nxt = a * 16
	else:
		var a = rng.randi_range(1, 4)
		for i in 4:
			seq.append((a + i) * (a + i))
		nxt = (a + 4) * (a + 4)
	var txt = []
	for v in seq:
		txt.append(str(v))
	prompt.text = ", ".join(txt) + ", ?"
	prompt.add_theme_font_size_override("font_size", 90)
	num_opts(nxt, 9)
