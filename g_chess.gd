extends "res://base.gd"
# شطرنج: لاعبين = قوانين كاملة | 3-4 لاعبين = قوانين Chess.com (لوحة 14x14، نقاط، كش مات، موت اللاعب)
const DIRV = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const ROOK = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const DIAG = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const KN = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
const VAL = {"P": 1, "N": 3, "B": 5, "R": 5, "Q": 9, "K": 0}
const CN_AR = ["الأحمر", "الأزرق", "الأصفر", "الأخضر"]
const CN_EN = ["Red", "Blue", "Yellow", "Green"]
const WB_AR = ["الأبيض", "", "الأسود", ""]
const WB_EN = ["White", "", "Black", ""]
var SC4 = [Color("e53935"), Color("1e88e5"), Color("fdd835"), Color("43a047")]
var SC2 = [Color("f4f4f6"), Color("000000"), Color("34343c"), Color("000000")]
var TC4 = [Color("ff8a80"), Color("82b1ff"), Color("fff59d"), Color("a5d6a7")]
var TC2 = [Color("ffffff"), Color("000000"), Color("d0d0dc"), Color("000000")]
var BACKS = [["R", "N", "B", "Q", "K", "B", "N", "R"], ["R", "N", "B", "K", "Q", "B", "N", "R"], ["R", "N", "B", "K", "Q", "B", "N", "R"], ["R", "N", "B", "Q", "K", "B", "N", "R"]]
var S = 8
var two = true
var board = {}
var order = []
var dead = {}
var points = [0, 0, 0, 0]
var cur = 0
var sel = null
var legal_moves = []
var eps = []
var lastmv = []
var checked = []
var promo = null
var promo_rects = []
var anim = null
var cell = 40.0
var ox = 0.0
var oy = 0.0
var flip = false

func build() -> void:
	two = players == 2
	S = 8 if two else 14
	if two:
		order = [0, 2]
	elif players == 3:
		order = [0, 1, 2]
	else:
		order = [0, 1, 2, 3]
	cur = order[0]
	flip = online and two and my_seat == 1
	for o in order:
		var back = BACKS[0] if two else BACKS[o]
		for i in 8:
			var a = ipos(o, i)
			board[a] = [o, back[i], false, false]
			board[a + DIRV[o]] = [o, "P", false, false]
	canvas(paint, inp)
	announce()

func ipos(o: int, i: int) -> Vector2i:
	var off = (S - 8) / 2
	match o:
		0:
			return Vector2i(off + i, S - 1)
		1:
			return Vector2i(0, off + i)
		2:
			return Vector2i(off + i, 0)
	return Vector2i(S - 1, off + i)

func pidx(o: int, p: Vector2i) -> int:
	var off = (S - 8) / 2
	return p.x - off if (o == 0 or o == 2) else p.y - off

func kfile(o: int) -> int:
	return (BACKS[0] if two else BACKS[o]).find("K")

func rank_index(p: Vector2i, o: int) -> int:
	match o:
		0:
			return S - 1 - p.y
		1:
			return p.x
		2:
			return p.y
	return S - 1 - p.x

func pcol(o: int) -> Color:
	return SC2[o] if two else SC4[o]

func cname(o: int) -> String:
	return Games.L(WB_AR[o], WB_EN[o]) if two else Games.L(CN_AR[o], CN_EN[o])

func other(o: int) -> int:
	return order[1 - order.find(o)]

func announce() -> void:
	var tc = TC2[cur] if two else TC4[cur]
	if online and cur == order[my_seat]:
		say(Games.L("دورك!", "Your turn!"), tc)
	else:
		say(Games.L("دور ", "Turn: ") + cname(cur), tc)

func sp(v: Vector2i) -> Vector2:
	var q = Vector2i(S - 1 - v.x, S - 1 - v.y) if flip else v
	return Vector2(ox + q.x * cell, oy + q.y * cell)

func mine() -> bool:
	return (not online) or cur == order[my_seat]

func ok(v: Vector2i) -> bool:
	if v.x < 0 or v.y < 0 or v.x >= S or v.y >= S:
		return false
	if S == 14 and (v.x < 3 or v.x > 10) and (v.y < 3 or v.y > 10):
		return false
	return true

func hostile(pc, defender: int) -> bool:
	return pc[0] != defender and not dead.has(pc[0])

func ep_entry(sq: Vector2i, o: int) -> Variant:
	for e in eps:
		if e[0] == sq and e[2] != o:
			return e
	return null

func add(out: Array, t: Vector2i, o: int, bd: Dictionary, kings: bool) -> void:
	if not ok(t):
		return
	if not bd.has(t):
		out.append(t)
	elif bd[t][0] != o and (kings or bd[t][1] != "K" or dead.has(bd[t][0])):
		out.append(t)

func gen(pos: Vector2i, bd: Dictionary, kings: bool = false) -> Array:
	var pc = bd[pos]
	var o = pc[0]
	var out = []
	if dead.has(o):
		return out
	match pc[1]:
		"P":
			var f = DIRV[o]
			var s = Vector2i(-f.y, f.x)
			var one = pos + f
			if ok(one) and not bd.has(one):
				out.append(one)
				var tw = one + f
				if not pc[2] and ok(tw) and not bd.has(tw):
					out.append(tw)
			for side in [s, -s]:
				var t = pos + f + side
				if not ok(t):
					continue
				if bd.has(t):
					if bd[t][0] != o and (kings or bd[t][1] != "K" or dead.has(bd[t][0])):
						out.append(t)
				elif ep_entry(t, o) != null:
					out.append(t)
		"N":
			for d in KN:
				add(out, pos + d, o, bd, kings)
		"K":
			for d in ROOK + DIAG:
				add(out, pos + d, o, bd, kings)
			if not pc[2] and not kings:
				castle(out, pos, o, bd)
		_:
			var dirs = []
			if pc[1] != "B":
				dirs += ROOK
			if pc[1] != "R":
				dirs += DIAG
			for d in dirs:
				var t = pos + d
				while ok(t):
					if bd.has(t):
						add(out, t, o, bd, kings)
						break
					out.append(t)
					t += d
	return out

func castle(out: Array, pos: Vector2i, o: int, bd: Dictionary) -> void:
	var kf = kfile(o)
	if pos != ipos(o, kf) or attacked(pos, o, bd):
		return
	for rf in [0, 7]:
		var rp = ipos(o, rf)
		if not (bd.has(rp) and bd[rp][1] == "R" and bd[rp][0] == o and not bd[rp][2]):
			continue
		var step = 1 if rf > kf else -1
		var clear = true
		var i = kf + step
		while i != rf:
			if bd.has(ipos(o, i)):
				clear = false
			i += step
		if not clear:
			continue
		if attacked(ipos(o, kf + step), o, bd) or attacked(ipos(o, kf + 2 * step), o, bd):
			continue
		out.append(ipos(o, kf + 2 * step))

func attacked(sq: Vector2i, defender: int, bd: Dictionary) -> bool:
	for d in KN:
		var p = sq + d
		if bd.has(p) and bd[p][1] == "N" and hostile(bd[p], defender):
			return true
	for d in ROOK + DIAG:
		var p = sq + d
		if bd.has(p) and bd[p][1] == "K" and hostile(bd[p], defender):
			return true
	for d in ROOK:
		var p = sq + d
		while ok(p):
			if bd.has(p):
				var pc = bd[p]
				if (pc[1] == "R" or pc[1] == "Q") and hostile(pc, defender):
					return true
				break
			p += d
	for d in DIAG:
		var p = sq + d
		while ok(p):
			if bd.has(p):
				var pc = bd[p]
				if (pc[1] == "B" or pc[1] == "Q") and hostile(pc, defender):
					return true
				break
			p += d
	for q in order:
		if q == defender or dead.has(q):
			continue
		var f = DIRV[q]
		var s = Vector2i(-f.y, f.x)
		for side in [s, -s]:
			var p = sq - f - side
			if bd.has(p) and bd[p][1] == "P" and bd[p][0] == q:
				return true
	return false

func king_pos(o: int, bd: Dictionary) -> Variant:
	for k in bd.keys():
		if bd[k][0] == o and bd[k][1] == "K":
			return k
	return null

func legal_for(pos: Vector2i) -> Array:
	var pc = board[pos]
	var o = pc[0]
	var res = []
	for d in gen(pos, board):
		var sim = board.duplicate()
		sim.erase(pos)
		if pc[1] == "P" and not board.has(d) and d.x != pos.x and d.y != pos.y:
			var e = ep_entry(d, o)
			if e != null:
				sim.erase(e[1])
		sim[d] = pc
		var kp = king_pos(o, sim)
		if kp != null and not attacked(kp, o, sim):
			res.append(d)
	return res

func has_any_legal(o: int) -> bool:
	for k in board.keys():
		if board[k][0] == o and legal_for(k).size() > 0:
			return true
	return false

func alive_list() -> Array:
	return order.filter(func(x): return not dead.has(x))

func only_kings() -> bool:
	var minors = 0
	for k in board.keys():
		var pc = board[k]
		if dead.has(pc[0]) or pc[1] == "K":
			continue
		if pc[1] == "B" or pc[1] == "N":
			minors += 1
		else:
			return false
	return minors <= 1 if two else minors == 0

func inp(e: InputEvent) -> void:
	if over:
		return
	if not (e is InputEventMouseButton and e.pressed):
		return
	if promo != null:
		for i in promo_rects.size():
			if promo_rects[i].has_point(e.position):
				var types = ["Q", "R", "B", "N"]
				var pm = promo
				promo = null
				act({"a": [pm[0].x, pm[0].y], "b": [pm[1].x, pm[1].y], "p": types[i]})
				body.queue_redraw()
				return
		return
	if not mine():
		return
	var v = Vector2i(floori((e.position.x - ox) / cell), floori((e.position.y - oy) / cell))
	if not ok(v):
		return
	if flip:
		v = Vector2i(S - 1 - v.x, S - 1 - v.y)
	if sel != null and legal_moves.has(v):
		var pc = board[sel]
		if two and pc[1] == "P" and rank_index(v, pc[0]) == 7:
			promo = [sel, v]
			sel = null
			legal_moves = []
		else:
			act({"a": [sel.x, sel.y], "b": [v.x, v.y], "p": ""})
			sel = null
			legal_moves = []
	elif board.has(v) and board[v][0] == cur and not dead.has(cur):
		sel = v
		legal_moves = legal_for(v)
		Sound.tone(700, 0.05, 2)
	else:
		sel = null
		legal_moves = []
	body.queue_redraw()

func on_action(_seat: int, d: Dictionary) -> void:
	if over:
		return
	var a = d.get("a", [0, 0])
	var b = d.get("b", [0, 0])
	var av = Vector2i(int(a[0]), int(a[1]))
	var bv = Vector2i(int(b[0]), int(b[1]))
	if not board.has(av) or board[av][0] != cur:
		return
	do_move(av, bv, str(d.get("p", "")))

func set_anim(t: float) -> void:
	if anim != null:
		anim[2] = t
	body.queue_redraw()

func end_anim() -> void:
	anim = null
	body.queue_redraw()

func do_move(a: Vector2i, b: Vector2i, ptype: String = "") -> void:
	var pc = board[a]
	var o = pc[0]
	var first = not pc[2]
	var cap = board.get(b)
	if pc[1] == "P" and cap == null and b.x != a.x and b.y != a.y:
		var e = ep_entry(b, o)
		if e != null:
			cap = board[e[1]]
			board.erase(e[1])
	board.erase(a)
	pc[2] = true
	if pc[1] == "K" and first and a == ipos(o, kfile(o)) and absi(pidx(o, b) - pidx(o, a)) == 2:
		var ka = pidx(o, a)
		var step = 1 if pidx(o, b) > ka else -1
		var rp = ipos(o, 7 if step > 0 else 0)
		var rk = board[rp]
		board.erase(rp)
		rk[2] = true
		board[ipos(o, ka + step)] = rk
	eps = eps.filter(func(en): return en[2] != o)
	if pc[1] == "P" and (a.x == b.x or a.y == b.y) and absi(b.x - a.x) + absi(b.y - a.y) == 2:
		eps.append([Vector2i((a.x + b.x) / 2, (a.y + b.y) / 2), b, o])
	if pc[1] == "P" and rank_index(b, o) == 7:
		pc[1] = ptype if (two and ptype != "") else "Q"
		pc[3] = true
	board[b] = pc
	if cap != null and not dead.has(cap[0]) and not two:
		points[o] += 1 if cap[3] else VAL[cap[1]]
	lastmv = [a, b]
	sel = null
	legal_moves = []
	checked = []
	anim = [a, b, 0.0]
	var tw = create_tween()
	tw.tween_method(set_anim, 0.0, 1.0, 0.2)
	tw.finished.connect(end_anim)
	if cap != null:
		Sound.tone(200, 0.2, 1)
	else:
		Sound.tone(520, 0.08, 2)
	if two:
		two_after(o)
	else:
		multi_after(o, b)
	body.queue_redraw()

func two_after(mover: int) -> void:
	cur = other(mover)
	var kp = king_pos(cur, board)
	var incheck = kp != null and attacked(kp, cur, board)
	if not has_any_legal(cur):
		if incheck:
			checked = [kp]
			finish(Games.L("كش مات! فاز ", "Checkmate! ") + cname(mover) + Games.L("", " wins"), Color.GOLD)
		else:
			finish(Games.L("تعادل (ستالميت)", "Stalemate - draw"), Color.WHITE)
	elif only_kings():
		finish(Games.L("تعادل (مواد غير كافية)", "Draw - insufficient material"), Color.WHITE)
	elif incheck:
		checked = [kp]
		say(Games.L("كش! دور ", "Check! ") + cname(cur), Color("ff6b6b"))
		Sound.tone(900, 0.15, 1)
	else:
		announce()

func multi_after(mover: int, dest: Vector2i) -> void:
	var n = 0
	for q in alive_list():
		if q == mover:
			continue
		var kq = king_pos(q, board)
		if kq != null and gen(dest, board, true).has(kq):
			n += 1
	if n == 2:
		points[mover] += 1
	elif n >= 3:
		points[mover] += 5
	if only_kings():
		end_game()
		return
	var i = order.find(mover)
	for guard in 8:
		i = (i + 1) % order.size()
		var cand = order[i]
		if dead.has(cand):
			continue
		var kp = king_pos(cand, board)
		var inc = kp != null and attacked(kp, cand, board)
		if has_any_legal(cand):
			cur = cand
			if inc:
				checked = [kp]
				say(Games.L("كش! دور ", "Check! ") + cname(cand), Color("ff6b6b"))
				Sound.tone(900, 0.15, 1)
			else:
				announce()
			return
		if inc:
			points[mover] += 20
		else:
			points[cand] += 20
		dead[cand] = true
		Sound.lose()
		if alive_list().size() <= 1:
			end_game()
			return
	announce()

func end_game() -> void:
	var best = order[0]
	for o in order:
		if points[o] > points[best]:
			best = o
	var tie = 0
	for o in order:
		if points[o] == points[best]:
			tie += 1
	if tie > 1:
		finish(Games.L("تعادل", "Draw") + "  " + str(points[best]), Color.WHITE)
	else:
		finish(Games.L("فاز ", "") + cname(best) + Games.L("", " wins") + "  (%d)" % points[best], TC4[best])

func paint() -> void:
	var f = ThemeDB.fallback_font
	var m = 14.0 if two else 4.0
	cell = minf((body.size.x - m * 2.0) / S, (body.size.y - m * 2.0) / S)
	ox = (body.size.x - cell * S) / 2.0
	oy = (body.size.y - cell * S) / 2.0
	if two:
		body.draw_style_box(Games.style(Color("2a2f45"), 26, 0), Rect2(ox - 16, oy - 16, cell * S + 32, cell * S + 32))
	var light = Color("e9edf5")
	var dark = Color("8c97b0")
	for y in S:
		for x in S:
			var v = Vector2i(x, y)
			if not ok(v):
				continue
			var r = Rect2(sp(v), Vector2(cell, cell))
			body.draw_rect(r, light if (x + y) % 2 == 0 else dark)
			if lastmv.has(v):
				body.draw_rect(r, Color(1, 0.9, 0.2, 0.38))
			if sel != null and sel == v:
				body.draw_rect(r, Color(0.2, 1, 0.5, 0.5))
			if checked.has(v):
				body.draw_circle(r.get_center(), cell * 0.55, Color(1, 0.1, 0.1, 0.55))
			if two:
				var fs = int(cell * 0.2)
				if (S - 1 - x if flip else x) == 0:
					body.draw_string(f, Vector2(r.position.x + 3, r.position.y + fs + 2), str(8 - y), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.2, 0.2, 0.3, 0.7))
				if (S - 1 - y if flip else y) == 7:
					body.draw_string(f, Vector2(r.position.x + cell - fs - 2, r.position.y + cell - 4), "abcdefgh".substr(x, 1), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.2, 0.2, 0.3, 0.7))
	var ps = cell * 0.95
	for k in board.keys():
		if anim != null and k == anim[1]:
			continue
		var pc = board[k]
		var fill = Color("8a8f98") if dead.has(pc[0]) else pcol(pc[0])
		Games.piece(body, pc[1], sp(k) + Vector2(cell, cell) / 2.0, ps, fill)
	if anim != null:
		var pc2 = board[anim[1]]
		var p0 = sp(anim[0]) + Vector2(cell, cell) / 2.0
		var p1 = sp(anim[1]) + Vector2(cell, cell) / 2.0
		var tt = anim[2]
		tt = 1.0 - pow(1.0 - tt, 3.0)
		Games.piece(body, pc2[1], p0.lerp(p1, tt) + Vector2(0, -sin(tt * PI) * cell * 0.15), ps, pcol(pc2[0]))
	for m2 in legal_moves:
		var c2 = sp(m2) + Vector2(cell, cell) / 2.0
		if board.has(m2) or (sel != null and board[sel][1] == "P" and m2.x != sel.x and m2.y != sel.y):
			body.draw_arc(c2, cell * 0.44, 0, TAU, 28, Color("ff4757"), cell * 0.07)
		else:
			body.draw_circle(c2, cell * 0.16, Color(0.1, 0.7, 0.3, 0.75))
	if not two:
		var corners = {0: Vector2(0, S - 3), 1: Vector2(0, 0), 2: Vector2(S - 3, 0), 3: Vector2(S - 3, S - 3)}
		for o in order:
			var c = corners[o]
			var r = Rect2(ox + c.x * cell, oy + c.y * cell, cell * 3, cell * 3)
			var base = Color("5c6370") if dead.has(o) else pcol(o)
			body.draw_style_box(Games.style(base, int(cell * 0.4), 5), r.grow(-3))
			var ink = Color.BLACK if (o == 2 and not dead.has(o)) else Color.WHITE
			body.draw_string(f, r.position + Vector2(8, cell * 0.8), cname(o), HORIZONTAL_ALIGNMENT_LEFT, cell * 2.8, int(cell * 0.4), ink)
			body.draw_string(f, r.position + Vector2(8, cell * 2.1), str(points[o]), HORIZONTAL_ALIGNMENT_LEFT, cell * 2.8, int(cell * 0.95), ink)
			if o == cur and not dead.has(o):
				body.draw_arc(r.get_center(), cell * 1.5, 0, TAU, 32, Color.WHITE, 5.0)
	if promo != null:
		body.draw_rect(Rect2(Vector2.ZERO, body.size), Color(0, 0, 0, 0.65))
		var w = minf(cell * 1.3, 130.0)
		var total = 4.0 * w + 3.0 * 14.0
		var sx = (body.size.x - total) / 2.0
		var sy = body.size.y / 2.0 - w / 2.0
		promo_rects = []
		var types2 = ["Q", "R", "B", "N"]
		for i in 4:
			var rc = Rect2(sx + i * (w + 14.0), sy, w, w)
			promo_rects.append(rc)
			body.draw_style_box(Games.style(Color("4a4f6a"), 22, 6), rc)
			Games.piece(body, types2[i], rc.get_center(), w * 0.85, pcol(cur))
