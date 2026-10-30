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
	next_round()

func flash(i: int, ms: float = 0.4) -> void:
	pads[i].modulate = Color.WHITE
	Sound.tone(260 + i * 100, ms, 0, -4.0)
	if not await wait(ms):
		return
	pads[i].modulate = Color(0.5, 0.5, 0.5)

func next_round() -> void:
	accept = false
	seq.append(randi() % 4)
	say("👀 شاهد... المستوى %d" % seq.size())
	if not await wait(0.8):
		return
	for s in seq:
		await flash(s)
		if not await wait(0.15):
			return
	accept = true
	idx = 0
	say("🎵 دورك!", Color("3ddc97"))

func tap(i: int) -> void:
	if not accept or over:
		return
	flash(i, 0.2)
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
		finish("❌ وصلت للمستوى %d" % seq.size(), Color("ff7675"))
