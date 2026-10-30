extends "res://base.gd"
var cards = []
var bs = []
var arts = []
var open = []
var scores = []
var lock = false
var busy = false
var found = 0
var moves = 0

func build() -> void:
	for i in 10:
		cards.append(i)
		cards.append(i)
	cards.shuffle()
	for i in players:
		scores.append(0)
	var g = center_grid(4, 14)
	for i in 20:
		var b = Games.btn("", Color("7d3fd0"), 150, 70)
		b.custom_minimum_size = Vector2(150, 150)
		b.pressed.connect(flip.bind(i))
		var a = Control.new()
		a.set_script(load("res://art.gd"))
		a.set("kind", "sym")
		a.set("idx", cards[i])
		a.set_anchors_preset(Control.PRESET_FULL_RECT)
		a.visible = false
		b.add_child(a)
		g.add_child(b)
		bs.append(b)
		arts.append(a)
		Games.pop(b, i * 0.025)
	refresh()

func reveal(i: int, up: bool) -> void:
	var b = bs[i]
	b.pivot_offset = b.size / 2
	var t = create_tween()
	t.tween_property(b, "scale:x", 0.0, 0.1)
	await t.finished
	arts[i].visible = up
	Games.tint(b, Color("f5f6fa") if up else Color("7d3fd0"))
	t = create_tween()
	t.tween_property(b, "scale:x", 1.0, 0.1)
	await t.finished

func flip(i: int) -> void:
	if lock or over or open.has(i) or bs[i].disabled or busy or not my_turn():
		return
	act({"i": i})

func is_busy() -> bool:
	return busy

func on_action(_seat: int, d: Dictionary) -> void:
	if over:
		return
	do_flip(int(d.get("i", 0)))

func do_flip(i: int) -> void:
	if open.has(i) or bs[i].disabled:
		return
	busy = true
	open.append(i)
	Sound.tone(600, 0.06, 2)
	await reveal(i, true)
	if open.size() < 2:
		busy = false
		pump()
		return
	var a = open[0]
	var b = open[1]
	moves += 1
	await get_tree().create_timer(0.7).timeout
	if cards[a] == cards[b]:
		scores[turn] += 1
		found += 1
		Sound.tone(900, 0.2, 2)
		for k in [a, b]:
			bs[k].disabled = true
			Games.tint(bs[k], col(turn).lightened(0.5))
	else:
		await reveal(a, false)
		await reveal(b, false)
		if players > 1:
			turn = (turn + 1) % players
	open.clear()
	refresh()
	busy = false
	if found == 10:
		if players == 1:
			finish("خلصت في %d حركة" % moves)
		else:
			var best = 0
			for i2 in players:
				if scores[i2] > scores[best]:
					best = i2
			if scores.count(scores[best]) > 1:
				finish("تعادل", Color.WHITE)
			else:
				finish("فاز " + Games.PN[best], col(best))
	pump()

func refresh() -> void:
	if players == 1:
		say("الحركات: %d" % moves)
	else:
		var s = ""
		for i in players:
			s += "%d " % scores[i]
		say("دور %s  |  %s" % [Games.PN[turn], s], col(turn))
