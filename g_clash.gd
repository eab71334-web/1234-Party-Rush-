extends "res://base.gd"
var hands = []
var deck = []
var discard = []
var cur = 0
var dir = 1
var choosing = -1
var hand_rects = []
var pile_rect = Rect2()
var drew = false
var drawn_idx = -1
var call_flag = false
var last_rect = Rect2()

func make_deck() -> Array:
	var d = []
	for c in 4:
		d.append([c, "0"])
		for n in range(1, 10):
			d.append([c, str(n)])
			d.append([c, str(n)])
		for k in ["skip", "rev", "d2"]:
			d.append([c, k])
			d.append([c, k])
	for i in 4:
		d.append([4, "wild"])
		d.append([4, "d4"])
	return d

func is_plain(c) -> bool:
	return c[0] < 4 and c[1].is_valid_int()

func is_wild(c) -> bool:
	return c[0] == 4

func playable(c) -> bool:
	if c[1] == "d4":
		for h in hands[turn]:
			if h[0] == cur:
				return false
	return c[0] == 4 or c[0] == cur or c[1] == discard.back()[1]

func cur_color() -> Color:
	return Games.ccolor(cur)

func draw_c(r: Rect2, c, up: bool, dim: bool) -> void:
	if c == null:
		Games.ccard(body, r, 4, "", false, false)
	else:
		Games.ccard(body, r, c[0], c[1], up, dim)

func choice_draw(i: int, ctr: Vector2, rad: float) -> void:
	body.draw_circle(ctr, rad, Games.ccolor(i))
	body.draw_arc(ctr, rad, 0, TAU, 24, Color.WHITE, 5.0)

func after_play(c, seat: int, choice: int) -> int:
	cur = c[0] if c[0] < 4 else clampi(choice, 0, 3)
	match c[1]:
		"skip":
			return 2
		"rev":
			dir = -dir
			return 2 if players == 2 else 1
		"d2":
			give(posmod(seat + dir, players), 2)
			return 2
		"d4":
			give(posmod(seat + dir, players), 4)
			return 2
	return 1

func build() -> void:
	landscape()
	deck = make_deck()
	rshuffle(deck)
	for s in players:
		var h = []
		for k in 7:
			h.append(deck.pop_back())
		hands.append(h)
	var first = deck.pop_back()
	while not is_plain(first):
		deck.insert(0, first)
		first = deck.pop_back()
	discard.append(first)
	cur = first[0]
	canvas(paint, inp)
	show_turn()

func draw_one():
	if deck.is_empty() and discard.size() > 1:
		var top = discard.back()
		deck = discard.slice(0, discard.size() - 1)
		discard = [top]
		rshuffle(deck)
	if deck.is_empty():
		return null
	return deck.pop_back()

func give(s: int, n: int) -> void:
	for k in n:
		var c = draw_one()
		if c != null:
			hands[s].append(c)

func advance(n: int) -> void:
	drew = false
	drawn_idx = -1
	turn = posmod(turn + dir * n, players)
	show_turn()

func on_action(seat: int, d: Dictionary) -> void:
	if over or seat != turn:
		return
	var t = d.get("t", "")
	if t == "d":
		if drew:
			advance(1)
		else:
			var c = draw_one()
			Sound.tone(500, 0.06, 2)
			if c == null:
				advance(1)
			else:
				hands[seat].append(c)
				if playable(c):
					drew = true
					drawn_idx = hands[seat].size() - 1
					say(Games.L("العب الورقة أو اضغط السحب للتمرير", "Play it, or tap the pile to pass"), col(seat))
				else:
					advance(1)
	elif t == "p":
		var i = int(d.get("i", -1))
		if i < 0 or i >= hands[seat].size():
			return
		if drew and i != drawn_idx:
			return
		var c = hands[seat][i]
		if not playable(c):
			return
		hands[seat].remove_at(i)
		discard.append(c)
		drew = false
		var steps = after_play(c, seat, int(d.get("c", 0)))
		Sound.tone(700, 0.08, 2)
		if hands[seat].size() == 1 and not bool(d.get("u", false)):
			give(seat, 2)
			Sound.lose()
		if hands[seat].is_empty():
			finish("فاز " + Games.PN[seat], col(seat))
			body.queue_redraw()
			return
		advance(steps)
	body.queue_redraw()

func me() -> int:
	return my_seat if online else turn

func paint() -> void:
	var W = body.size.x
	var H = body.size.y
	var f = ThemeDB.fallback_font
	var m = me()
	var ch = minf(H * 0.28, 220.0)
	var cw = ch * 0.68
	var others = []
	for s in players:
		if s != m:
			others.append(s)
	for k in others.size():
		var s = others[k]
		var x = W * (k + 0.5) / others.size()
		var pr = Rect2(x - 150, 6, 300, 62)
		var active = (s == turn)
		body.draw_style_box(Games.style(Games.PC[s].darkened(0.0 if active else 0.5), 28, 5), pr)
		body.draw_string(f, pr.position + Vector2(20, 42), "%s  x%d" % [Games.PN[s], hands[s].size()], HORIZONTAL_ALIGNMENT_LEFT, 270, 30, Color.WHITE)
		for j in mini(hands[s].size(), 8):
			draw_c(Rect2(x - 150 + j * 20, 82, 54, 78), null, false, false)
	var cy = H * 0.5 - ch * 0.62
	var dc = Vector2(W / 2.0 + cw * 0.75, cy + ch / 2.0)
	pile_rect = Rect2(W / 2.0 - cw * 1.75, cy, cw, ch)
	for j in 3:
		draw_c(Rect2(pile_rect.position + Vector2(j * 4, -j * 4), pile_rect.size), null, false, false)
	var cc = cur_color()
	body.draw_circle(dc, ch * 0.68, Color(cc.r, cc.g, cc.b, 0.3))
	draw_c(Rect2(dc - Vector2(cw, ch) / 2.0, Vector2(cw, ch)), discard.back(), true, false)
	var ty = cy + ch + 22
	var tri = PackedVector2Array([Vector2(W / 2.0 - 40 * dir, ty), Vector2(W / 2.0 + 40 * dir, ty + 18), Vector2(W / 2.0 - 40 * dir, ty + 36)]) if false else PackedVector2Array([Vector2(W / 2.0 + 40 * dir, ty + 18), Vector2(W / 2.0 - 30 * dir, ty), Vector2(W / 2.0 - 30 * dir, ty + 36)])
	body.draw_colored_polygon(tri, Color(1, 1, 1, 0.6))
	hand_rects = []
	var hand = hands[m]
	var n = hand.size()
	var sp = minf(cw * 0.8, (W - cw - 60.0) / maxf(n - 1, 1))
	var x0 = (W - (sp * (n - 1) + cw)) / 2.0
	var y0 = H - ch - 16.0
	var mine = (turn == m)
	var any = false
	for i in n:
		var ok = playable(hand[i]) and (not drew or i == drawn_idx)
		if ok:
			any = true
		var lift = 24.0 if (mine and ok) else 0.0
		draw_c(Rect2(x0 + sp * i, y0 - lift, cw, ch), hand[i], true, mine and not ok)
		hand_rects.append(Rect2(x0 + sp * i, y0 - 24.0, sp if i < n - 1 else cw, ch + 24.0))
	last_rect = Rect2()
	if mine and hand.size() == 2:
		last_rect = Rect2(W - 230, H * 0.5 - 40, 200, 80)
		body.draw_style_box(Games.style(Color("ff9f1a") if call_flag else Color("57606f"), 30, 5), last_rect)
		body.draw_string(f, last_rect.position + Vector2(0, 52), Games.L("آخر ورقة!", "LAST!"), HORIZONTAL_ALIGNMENT_CENTER, 200, 34, Color.WHITE)
	if mine and not any:
		body.draw_arc(pile_rect.get_center(), cw * 0.8, 0, TAU, 28, Color(1, 1, 0.3, 0.8), 6.0)
	if choosing >= 0:
		body.draw_rect(Rect2(Vector2.ZERO, body.size), Color(0, 0, 0, 0.6))
		for i in 4:
			choice_draw(i, Vector2(W / 2.0 + (i - 1.5) * 150.0, H * 0.45), 60.0)

func inp(e: InputEvent) -> void:
	if over or not (e is InputEventMouseButton and e.pressed):
		return
	if not my_turn():
		return
	var p = e.position
	var W = body.size.x
	var H = body.size.y
	if choosing >= 0:
		for i in 4:
			if p.distance_to(Vector2(W / 2.0 + (i - 1.5) * 150.0, H * 0.45)) < 70.0:
				var idx = choosing
				choosing = -1
				act({"t": "p", "i": idx, "c": i, "u": call_flag})
				call_flag = false
				body.queue_redraw()
				return
		choosing = -1
		body.queue_redraw()
		return
	if last_rect.size.x > 0 and last_rect.has_point(p):
		call_flag = not call_flag
		body.queue_redraw()
		return
	if pile_rect.grow(30).has_point(p):
		act({"t": "d"})
		return
	var hand = hands[me()]
	for i in range(hand_rects.size() - 1, -1, -1):
		if hand_rects[i].has_point(p):
			if not playable(hand[i]) or (drew and i != drawn_idx):
				Sound.tone(150, 0.1, 1)
				return
			if is_wild(hand[i]):
				choosing = i
				body.queue_redraw()
				return
			act({"t": "p", "i": i, "u": call_flag})
			call_flag = false
			return
