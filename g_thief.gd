extends "res://base.gd"
var decks = []
var piles = []
var out = []
var flips = 0
var fb: Button
var fly = []
var flip_t = {}
var steal_flash = {}

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

func show_turn() -> void:
	super.show_turn()
	if fb != null:
		fb.disabled = over or (online and turn != my_seat)

func _process(d: float) -> void:
	super._process(d)
	var busy = false
	for k in flip_t.keys():
		flip_t[k] += d
		if flip_t[k] >= 0.25:
			flip_t.erase(k)
	for k in steal_flash.keys():
		steal_flash[k] += d
		if steal_flash[k] >= 0.6:
			steal_flash.erase(k)
	for f in fly:
		f[3] += d
	fly = fly.filter(func(f): return f[3] < 0.45)
	if not flip_t.is_empty() or not steal_flash.is_empty() or not fly.is_empty():
		body.queue_redraw()

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

func zone_rect(s: int) -> Rect2:
	var W = body.size.x
	var H = body.size.y - 150.0
	var cols = 2 if players > 2 else players
	var rows = ceili(players / float(cols))
	var pw = W / cols
	var ph = H / rows
	return Rect2((s % cols) * pw + 10, (s / cols) * ph + 10, pw - 20, ph - 20)

func card_geo(s: int) -> Array:
	var r = zone_rect(s)
	var cw = minf(r.size.x * 0.34, (r.size.y - 80.0) * 0.68)
	var chh = cw / 0.68
	var cy = r.position.y + 56.0
	var deck_p = Vector2(r.position.x + r.size.x * 0.12, cy)
	var pile_p = Vector2(r.position.x + r.size.x * 0.52, cy)
	return [Vector2(cw, chh), deck_p, pile_p]

func on_action(seat: int, _d: Dictionary) -> void:
	if over or seat != turn:
		return
	if decks[seat].is_empty():
		out[seat] = true
		next_alive()
		return
	var c = decks[seat].pop_front()
	piles[seat].append(c)
	flip_t[seat] = 0.0
	flips += 1
	Sound.tone(450 + c[1] * 20, 0.05, 2)
	var stolen = false
	for s in players:
		if s != seat and not piles[s].is_empty() and piles[s].back()[1] == c[1]:
			var geo_v = card_geo(s)
			var geo_t = card_geo(seat)
			fly.append([piles[s].back(), geo_v[2], geo_t[1], 0.0, geo_v[0]])
			steal_flash[seat] = 0.0
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
	var f = ThemeDB.fallback_font
	for s in players:
		var r = zone_rect(s)
		var base = Games.PC[s].darkened(0.1 if s == turn else 0.55)
		if steal_flash.has(s):
			base = base.lightened(0.4 * (1.0 - steal_flash[s] / 0.6))
		body.draw_style_box(Games.style(base, 30, 6), r)
		body.draw_string(f, r.position + Vector2(18, 40), "%s  (%d)" % [Games.PN[s], total(s)], HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 30, 30, Color.WHITE)
		var geo = card_geo(s)
		var sz = geo[0]
		if not decks[s].is_empty():
			Games.pcard(body, Rect2(geo[1], sz), 1, 0, false)
		if not piles[s].is_empty():
			var c = piles[s].back()
			var k = 1.0
			if flip_t.has(s):
				k = flip_t[s] / 0.25
			var sc2 = 0.6 + 0.4 * (1.0 - pow(1.0 - k, 3.0))
			var ctr = geo[2] + sz / 2.0
			body.draw_set_transform(ctr, 0.0, Vector2(sc2, sc2))
			Games.pcard(body, Rect2(-sz / 2.0, sz), c[1], c[0], true)
			body.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for fl in fly:
		var k2 = 1.0 - pow(1.0 - clampf(fl[3] / 0.45, 0.0, 1.0), 3.0)
		Games.pcard(body, Rect2(fl[1].lerp(fl[2], k2), fl[4]), fl[0][1], fl[0][0], true)
