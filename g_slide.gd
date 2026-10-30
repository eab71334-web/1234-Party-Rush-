extends "res://base.gd"
var t = []
var bs = []
var moves = 0

func build() -> void:
	for i in 16:
		t.append((i + 1) % 16)
	var e = 15
	for k in 250:
		var r = e / 4
		var c = e % 4
		var nb = []
		if r > 0:
			nb.append(e - 4)
		if r < 3:
			nb.append(e + 4)
		if c > 0:
			nb.append(e - 1)
		if c < 3:
			nb.append(e + 1)
		var m = nb.pick_random()
		t[e] = t[m]
		t[m] = 0
		e = m
	var g = center_grid(4, 12)
	for i in 16:
		var b = Games.btn("", Color("fc5c65"), 160, 70)
		b.custom_minimum_size = Vector2(160, 160)
		b.pressed.connect(press.bind(i))
		g.add_child(b)
		bs.append(b)
	refresh()

func refresh() -> void:
	for i in 16:
		bs[i].text = str(t[i]) if t[i] != 0 else ""
		bs[i].modulate = Color.WHITE if t[i] != 0 else Color(1, 1, 1, 0)
	say("🧩 الحركات: %d" % moves)

func press(i: int) -> void:
	if over:
		return
	var e = t.find(0)
	if absi(i / 4 - e / 4) + absi(i % 4 - e % 4) != 1:
		return
	t[e] = t[i]
	t[i] = 0
	moves += 1
	Sound.tone(500, 0.05, 2)
	refresh()
	for k in 15:
		if t[k] != k + 1:
			return
	finish("🎉 حليتها في %d حركة" % moves)
