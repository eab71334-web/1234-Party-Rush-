extends "res://base.gd"
var seq = []
var idx = 0
var accept = false
var pads = []

func build() -> void:
	var g = center_grid(2, 20)
	for i in 4:
		var b = Games.btn("", col(i), 300, 40)
		b.custom_minimum_size = Vector2(300, 300)
		b.modulate = Color(0.5, 0.5, 0.5)
		b.button_down.connect(tap.bind(i))
		g.add_child(b)
		pads.append(b)
		Games.pop(b, i * 0.08)
	next_round()

func dur() -> float:
	return maxf(0.18, 0.42 - seq.size() * 0.015)

func glow(i: int, t: float) -> void:
	var b = pads[i]
	b.modulate = Color.WHITE
	b.pivot_offset = b.size / 2.0
	b.scale = Vector2(1.06, 1.06)
	Sound.tone(260 + i * 100, t, 0, -4.0)
	if not await wait(t):
		return
	b.modulate = Color(0.5, 0.5, 0.5)
	b.scale = Vector2.ONE

func next_round() -> void:
	accept = false
	seq.append(randi() % 4)
	say("👀 شاهد... المستوى %d" % seq.size())
	if not await wait(0.8):
		return
	for s in seq:
		await glow(s, dur())
		if not await wait(0.12):
			return
	accept = true
	idx = 0
	say("🎵 دورك!", Color("3ddc97"))

func tap(i: int) -> void:
	if not accept or over:
		return
	glow(i, 0.2)
	if seq[idx] == i:
		idx += 1
		if idx == seq.size():
			accept = false
			if not await wait(0.7):
				return
			next_round()
	else:
		accept = false
		Sound.lose()
		for b in pads:
			b.modulate = Color(1.0, 0.45, 0.45)
		finish("❌ وصلت للمستوى %d" % seq.size(), Color("ff7675"))
