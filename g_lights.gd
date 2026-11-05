extends "res://base.gd"
const N = 5
var on = []
var start_state = []
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
		Games.pop(b, i * 0.02)
	while not on.has(true):
		for k in 14:
			toggle(randi() % (N * N))
	start_state = on.duplicate()
	var rb = Games.btn(Games.L("إعادة", "Restart"), Color("636e72"), 90, 34)
	rb.set_anchors_preset(PRESET_BOTTOM_WIDE)
	rb.offset_top = -110
	rb.offset_bottom = -10
	rb.offset_left = 80
	rb.offset_right = -80
	rb.pressed.connect(restart)
	body.add_child(rb)
	refresh()
	say("💡 أطفئ كل الأضواء")

func restart() -> void:
	if over:
		return
	on = start_state.duplicate()
	moves = 0
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

func bump(i: int) -> void:
	var b = bs[i]
	b.pivot_offset = b.size / 2.0
	b.scale = Vector2(0.85, 0.85)
	create_tween().tween_property(b, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func press(i: int) -> void:
	if over:
		return
	toggle(i)
	moves += 1
	Sound.tone(440 + (i % N) * 60, 0.08, 2)
	refresh()
	bump(i)
	var r = i / N
	var c = i % N
	if r > 0:
		bump(i - N)
	if r < N - 1:
		bump(i + N)
	if c > 0:
		bump(i - 1)
	if c < N - 1:
		bump(i + 1)
	say("💡 الحركات: %d" % moves)
	if not on.has(true):
		finish("🎉 أطفأتها في %d حركة" % moves)
