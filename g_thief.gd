extends "res://base.gd"
var decks = []
var piles = []
var out = []
var flips = 0
var fb: Button
var note = ""

func build() -> void:
	var all = []
	for s in 4:
		for r in range(1, 14):
			all.append([s, r])
	rshuffle(all)
	for p in players:
		decks.append([])
		piles.append([])
		out.append(false)
	for i in all.size():
		decks[i % players].append(all[i])
	canvas(paint, noop)
	fb = Games.btn(Games.L("اقلب الورقة", "Flip card"), col(my_seat if online else 0), 120, 48)
	fb.set_anchors_preset(PRESET_BOTTOM_WIDE)
	fb.offset_top = -140
	fb.offset_bottom = -10
	fb.offset_left = 40
	fb.offset_right = -40
	fb.button_down.connect(flip_pressed)
	body.add_child(fb)
	show_turn()

func flip_pressed() -> void:
	if over or not my_turn():
		return
	act({"t": "f"})

func total(s: int) -> int:
	return decks[s].size() + piles[s].size()

func alive_count() -> int:
	var n = 0
	for s in players:
		if not out[s]:
			n += 1
	return n

func next_alive() -> void:
	for k in players:
		turn = (turn + 1) % players
		if decks[turn].is_empty():
			out[turn] = true
		if not out[turn]:
			break
	show_turn()

func on_action(seat: int, _d: Dictionary) -> void:
	if over or seat != turn:
		return
	if decks[seat].is_empty():
		out[seat] = true
		next_alive()
		return
	var c = decks[seat].pop_front()
	piles[seat].append(c)
	flips += 1
	Sound.tone(450 + c[1] * 20, 0.05, 2)
	var stolen = false
	for s in players:
		if s != seat and not piles[s].is_empty() and piles[s].back()[1] == c[1]:
			decks[seat].append_array(piles[s])
			decks[seat].append_array(piles[seat])
			piles[s] = []
			piles[seat] = []
			stolen = true
			Sound.tone(900, 0.2, 2)
			break
	if alive_count() <= 1 or flips >= 160:
		var best = 0
		for s in players:
			if total(s) > total(best):
				best = s
		finish("فاز " + Games.PN[best], col(best))
	elif stolen:
		show_turn()
	else:
		next_alive()
	body.queue_redraw()

func paint() -> void:
	var W = body.size.x
	var H = body.size.y - 150.0
	var f = ThemeDB.fallback_font
	var cols = 2 if players > 2 else players
	var rows = ceili(players / float(cols))
	var pw = W / cols
	var ph = H / rows
	for s in players:
		var r = Rect2((s % cols) * pw + 10, (s / cols) * ph + 10, pw - 20, ph - 20)
		body.draw_style_box(Games.style(Games.PC[s].darkened(0.1 if s == turn else 0.55), 30, 6), r)
		body.draw_string(f, r.position + Vector2(18, 40), "%s  (%d)" % [Games.PN[s], total(s)], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 30, 30, Color.WHITE)
		var cw = minf(r.size.x * 0.34, (r.size.y - 80.0) * 0.68)
		var chh = cw / 0.68
		var cy = r.position.y + 56.0
		if not decks[s].is_empty():
			Games.pcard(body, Rect2(r.position.x + r.size.x * 0.12, cy, cw, chh), 1, 0, false)
		if not piles[s].is_empty():
			var c = piles[s].back()
			Games.pcard(body, Rect2(r.position.x + r.size.x * 0.52, cy, cw, chh), c[1], c[0], true)
