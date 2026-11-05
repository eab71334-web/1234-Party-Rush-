extends "res://base.gd"
var hands = []
var picks = {}
var scores = []
var rnd = 0
var revealing = false
var rects = []
var rev_t = 0.0
var win_seat = -1
var tt = 0.0

func build() -> void:
	landscape()
	for s in players:
		scores.append(0)
		var h = []
		for k in 5:
			h.append([rng.randi() % 4, rng.randi_range(1, 13)])
		hands.append(h)
	canvas(paint, inp)
	say(Games.L("اختر ورقة سرّية", "Pick a secret card"), Color.WHITE)

func is_busy() -> bool:
	return revealing

func _process(d: float) -> void:
	super._process(d)
	tt += d
	if revealing:
		rev_t += d / 0.4
	if not over:
		body.queue_redraw()

func on_action(seat: int, d: Dictionary) -> void:
	if over or revealing or picks.has(seat):
		return
	var i = int(d.get("i", -1))
	if i < 0 or i >= hands[seat].size():
		return
	picks[seat] = i
	Sound.tone(500, 0.05, 2)
	body.queue_redraw()
	if picks.size() == players:
		resolve()

func resolve() -> void:
	revealing = true
	rev_t = 0.0
	win_seat = -1
	var bv = -1
	for s in players:
		bv = maxi(bv, hands[s][picks[s]][1])
	var winners = []
	for s in players:
		if hands[s][picks[s]][1] == bv:
			winners.append(s)
	if winners.size() == 1:
		win_seat = winners[0]
		scores[winners[0]] += 1
		say("فاز " + Games.PN[winners[0]], col(winners[0]))
		Sound.tone(900, 0.2, 2)
	else:
		say(Games.L("تعادل", "Draw"), Color.WHITE)
	body.queue_redraw()
	if not await wait(2.2):
		return
	for s in players:
		hands[s].remove_at(picks[s])
	picks = {}
	rnd += 1
	revealing = false
	win_seat = -1
	if rnd >= 5:
		var best = 0
		for s in players:
			if scores[s] > scores[best]:
				best = s
		if scores.count(scores[best]) > 1:
			finish(Games.L("تعادل", "Draw"), Color.WHITE)
		else:
			finish("فاز " + Games.PN[best], col(best))
	else:
		say(Games.L("اختر ورقة سرّية", "Pick a secret card"), Color.WHITE)
		body.queue_redraw()
		pump()

func paint() -> void:
	var W = body.size.x
	var H = body.size.y
	var f = ThemeDB.fallback_font
	var ch = minf(H * 0.26, 220.0)
	var cw = ch * 0.68
	for s in players:
		var x = W * (s + 0.5) / players
		var pr = Rect2(x - 130, 6, 260, 60)
		body.draw_style_box(Games.style(Games.PC[s].darkened(0.3), 28, 5), pr)
		body.draw_string(f, pr.position + Vector2(18, 40), "%s   %d" % [Games.PN[s], scores[s]], HORIZONTAL_ALIGNMENT_LEFT, 240, 30, Color.WHITE)
		var r = Rect2(x - cw / 2.0, H * 0.32 - ch / 2.0, cw, ch)
		if picks.has(s):
			var c = hands[s][picks[s]]
			if revealing:
				var k = clampf(rev_t, 0.0, 1.0)
				var sx = maxf(absf(cos(k * PI)), 0.05)
				body.draw_set_transform(r.get_center(), 0.0, Vector2(sx, 1.0))
				Games.pcard(body, Rect2(-r.size / 2.0, r.size), c[1], c[0], k > 0.5)
				body.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				if s == win_seat and k >= 1.0:
					body.draw_style_box(Games.flat(Color(1, 0.85, 0.2, 0.25 + 0.1 * sin(tt * 8.0)), 24), r.grow(14))
			else:
				Games.pcard(body, r, 1, 0, false)
		else:
			body.draw_style_box(Games.flat(Color(1, 1, 1, 0.1), 20), r)
	for i in 5:
		var dc = Color("ffd32a") if i < rnd else Color(1, 1, 1, 0.25)
		body.draw_circle(Vector2(W / 2.0 + (i - 2) * 34.0, H * 0.32 + ch / 2.0 + 30.0), 9.0, dc)
	var m = my_seat if online else 0
	var hand = hands[m]
	var n = hand.size()
	var sp = minf(cw * 1.1, (W - cw - 60.0) / maxf(n - 1, 1))
	var x0 = (W - (sp * (n - 1) + cw)) / 2.0
	var y0 = H - ch - 20.0
	rects = []
	for i in n:
		var lift = 30.0 if (picks.has(m) and picks[m] == i) else 0.0
		var r2 = Rect2(x0 + sp * i, y0 - lift, cw, ch)
		Games.pcard(body, r2, hand[i][1], hand[i][0], true, picks.has(m) and picks[m] != i)
		rects.append(Rect2(x0 + sp * i, y0 - 30.0, sp if i < n - 1 else cw, ch + 30.0))

func inp(e: InputEvent) -> void:
	if over or revealing or not (e is InputEventMouseButton and e.pressed):
		return
	var m = my_seat if online else 0
	if picks.has(m):
		return
	for i in range(rects.size() - 1, -1, -1):
		if rects[i].has_point(e.position):
			act({"i": i})
			return
