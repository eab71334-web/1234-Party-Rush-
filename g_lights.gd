extends "res://base.gd"
const N = 5
var on = []
var bs = []
var moves = 0

func build() -> void:
	for i in N * N:
		on.append(false)
	var g = center_grid(N, 12)
	for i in N * N:
		var b = Games.btn("", Color("2f2557"), 130, 40)
		b.custom_minimum_size = Vector2(125, 125)
		b.pressed.connect(press.bind(i))
		g.add_child(b)
		bs.append(b)
	for k in 14:
		toggle(randi() % (N * N))
	refresh()
	say("💡 أطفئ كل الأضواء")

func toggle(i: int) -> void:
	var r = i / N
	var c = i % N
	on[i] = not on[i]
	if r > 0:
		on[i - N] = not on[i - N]
	if r < N - 1:
		on[i + N] = not on[i + N]
	if c > 0:
		on[i - 1] = not on[i - 1]
	if c < N - 1:
		on[i + 1] = not on[i + 1]

func refresh() -> void:
	for i in N * N:
		Games.tint(bs[i], Color("ffd32a") if on[i] else Color("2f2557"))

func press(i: int) -> void:
	if over:
		return
	toggle(i)
	moves += 1
	Sound.tone(440 + (i % N) * 60, 0.08, 2)
	refresh()
	say("💡 الحركات: %d" % moves)
	if not on.has(true):
		finish("🎉 أطفأتها في %d حركة" % moves)
