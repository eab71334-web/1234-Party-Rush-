extends "res://base.gd"
# شطرنج: لاعبين = قوانين كاملة | 3-4 لاعبين = قوانين Chess.com (لوحة 14x14، نقاط، كش مات، موت اللاعب)
# + تراجع عن النقلة، سجل النقلات، عرض تعادل، وطلبات بموافقة الخصم أونلاين
const DIRV = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const ROOK = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const DIAG = [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const KN = [Vector2i(1, 2), Vector2i(2, 1), Vector2i(-1, 2), Vector2i(-2, 1), Vector2i(1, -2), Vector2i(2, -1), Vector2i(-1, -2), Vector2i(-2, -1)]
const VAL = {"P": 1, "N": 3, "B": 5, "R": 5, "Q": 9, "K": 0}
const CN_AR = ["الأحمر", "الأزرق", "الأصفر", "الأخضر"]
const CN_EN = ["Red", "Blue", "Yellow", "Green"]
const WB_AR = ["الأبيض", "", "الأسود", ""]
const WB_EN = ["White", "", "Black", ""]
const UI_H = 300.0
const FILES = "abcdefghijklmn"
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
var anim_tw: Tween = null
var cell = 40.0
var ox = 0.0
var oy = 0.0
var flip = false
# --- الجديد ---
var history = []          # كل عنصر: {"o": لون المحرّك, "san": نص النقلة, "snap": حالة ما قبل النقلة}
var pending = null        # طلب معلّق: {"k": undo/draw, "from": لون, "seat": مقعد, "need": عدد الموافقات, "yes": []}
var ui: VBoxContainer
var log_sc: ScrollContainer
var log_box: HFlowContainer
var btn_row: HBoxContainer
var btn_undo: Button
var btn_draw: Button
var dlg: Control = null
var toast_node: Control = null

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
	build_ui()
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
	if over or pending != null:
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

func on_action(seat: int, d: Dictionary) -> void:
	if over:
		return
	# رسائل الطلبات (تراجع / تعادل / رد / إلغاء)
	var t = str(d.get("t", ""))
	if t != "":
		meta(seat, t, d)
		return
	# لا نقلات أثناء وجود طلب معلّق
	if pending != null:
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

# ------------------------------------------------------------------
#  السجل والتراجع
# ------------------------------------------------------------------
func take_snap() -> Dictionary:
	return {
		"board": board.duplicate(true),
		"cur": cur,
		"dead": dead.duplicate(),
		"points": points.duplicate(),
		"eps": eps.duplicate(true),
		"lastmv": lastmv.duplicate(),
		"checked": checked.duplicate()
	}

func sq_name(v: Vector2i) -> String:
	return FILES.substr(v.x, 1) + str(S - v.y)

func make_san(ptype: String, a: Vector2i, b: Vector2i, was_cap: bool, castle_side: int, promo_t: String) -> String:
	if castle_side != 0:
		return "O-O" if castle_side > 0 else "O-O-O"
	var s = ""
	if ptype == "P":
		if was_cap:
			s += FILES.substr(a.x, 1)
	else:
		s += ptype
	if was_cap:
		s += "x"
	s += sq_name(b)
	if promo_t != "":
		s += "=" + promo_t
	return s

func last_index(o: int) -> int:
	for i in range(history.size() - 1, -1, -1):
		if history[i]["o"] == o:
			return i
	return -1

func ink(o: int) -> Color:
	if (two and o == 0) or ((not two) and o == 2):
		return Color.BLACK
	return Color.WHITE

func add_chip(i: int) -> void:
	var e = history[i]
	var o = e["o"]
	if two and o == order[0]:
		var n = Label.new()
		n.text = "%d." % (i / 2 + 1)
		n.add_theme_font_size_override("font_size", 26)
		n.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
		log_box.add_child(n)
	var sb = Games.flat(pcol(o), 14)
	sb.set_content_margin_all(5)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	if online and o == order[my_seat]:
		sb.set_border_width_all(3)
		sb.border_color = Color.GOLD
	else:
		sb.set_border_width_all(2)
		sb.border_color = Color(1, 1, 1, 0.25)
	var pn = PanelContainer.new()
	pn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pn.add_theme_stylebox_override("panel", sb)
	var l = Label.new()
	l.text = e["san"]
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", ink(o))
	pn.add_child(l)
	log_box.add_child(pn)

func rebuild_log() -> void:
	for c in log_box.get_children():
		log_box.remove_child(c)
		c.queue_free()
	for i in history.size():
		add_chip(i)
	scroll_log()

func scroll_log() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(log_sc):
		log_sc.scroll_vertical = int(log_sc.get_v_scroll_bar().max_value)

func do_undo_to(i: int) -> void:
	if i < 0 or i >= history.size():
		return
	var s = history[i]["snap"]
	board = s["board"].duplicate(true)
	cur = s["cur"]
	dead = s["dead"].duplicate()
	points = s["points"].duplicate()
	eps = s["eps"].duplicate(true)
	lastmv = s["lastmv"].duplicate()
	checked = s["checked"].duplicate()
	history.resize(i)
	sel = null
	legal_moves = []
	promo = null
	anim = null
	if anim_tw != null:
		anim_tw.kill()
		anim_tw = null
	Sound.tone(350, 0.12, 2)
	if checked.is_empty():
		announce()
	else:
		say(Games.L("كش! دور ", "Check! ") + cname(cur), Color("ff6b6b"))
	rebuild_log()
	update_buttons()
	body.queue_redraw()

# ------------------------------------------------------------------
#  الطلبات: تراجع / تعادل
# ------------------------------------------------------------------
func on_undo() -> void:
	if over or pending != null or promo != null or history.is_empty():
		return
	if online:
		if last_index(order[my_seat]) < 0:
			return
		act({"t": "req", "k": "undo"})
	else:
		do_undo_to(history.size() - 1)

func on_draw() -> void:
	if over or pending != null or promo != null or not two:
		return
	act({"t": "req", "k": "draw"})

func respond(accept: bool) -> void:
	act({"t": "resp", "ok": accept})

func cancel_req() -> void:
	act({"t": "cancel"})

func meta(seat: int, t: String, d: Dictionary) -> void:
	if online and (seat < 0 or seat >= order.size()):
		return
	match t:
		"req":
			if pending != null:
				return
			var k = str(d.get("k", ""))
			if k != "undo" and k != "draw":
				return
			if k == "draw" and not two:
				return
			var frm = order[seat] if online else cur
			if k == "undo" and last_index(frm) < 0:
				return
			pending = {"k": k, "from": frm, "seat": seat, "need": players - 1 if online else 1, "yes": []}
			sel = null
			legal_moves = []
			promo = null
			show_pending()
			update_buttons()
			body.queue_redraw()
		"resp":
			if pending == null:
				return
			var rs = seat if online else 0
			if online and (rs == pending["seat"] or pending["yes"].has(rs)):
				return
			var nm = cname(order[seat]) if online else cname(other(pending["from"]))
			if bool(d.get("ok", false)):
				pending["yes"].append(rs)
				if pending["yes"].size() >= pending["need"]:
					finish_request(true, nm)
				elif online and rs == my_seat:
					close_dialog()
					toast(Games.L("تم إرسال موافقتك", "Your acceptance was sent"), Color("2ed573"))
			else:
				finish_request(false, nm)
		"cancel":
			if pending == null:
				return
			if online and seat != pending["seat"]:
				return
			pending = null
			close_dialog()
			toast(Games.L("تم إلغاء الطلب", "Request cancelled"), Color("636e72"))
			update_buttons()

func finish_request(accepted: bool, nm: String) -> void:
	var p = pending
	pending = null
	close_dialog()
	var is_undo = p["k"] == "undo"
	var who = (nm + " ") if two else ""
	if accepted:
		if is_undo:
			var i = last_index(p["from"])
			if i >= 0:
				do_undo_to(i)
			toast(who + Games.L("وافق على التراجع", "accepted the undo"), Color("2ed573"))
		else:
			toast(who + Games.L("وافق على التعادل", "accepted the draw"), Color("2ed573"))
			update_buttons()
			finish(Games.L("تعادل بالاتفاق", "Draw by agreement"), Color.WHITE)
			return
	else:
		var msg = Games.L("رفض طلب التراجع", "declined the undo") if is_undo else Games.L("رفض عرض التعادل", "declined the draw")
		toast(nm + " " + msg, Color("ff4757"))
		say(nm + " " + msg, Color("ff6b6b"))
	update_buttons()

func show_pending() -> void:
	var p = pending
	if p == null:
		return
	var is_undo = p["k"] == "undo"
	var title = Games.L("طلب تراجع", "Undo request") if is_undo else Games.L("عرض تعادل", "Draw offer")
	if online and p["seat"] == my_seat:
		open_dialog(title, Games.L("بانتظار الرد...", "Waiting for a reply..."), [[Games.L("إلغاء الطلب", "Cancel request"), Color("636e72"), cancel_req]])
		return
	var who = cname(p["from"])
	var msg = ""
	if is_undo:
		msg = Games.L("%s يطلب التراجع عن آخر نقلة. هل توافق؟", "%s asks to take back the last move. Accept?") % who
	else:
		msg = Games.L("%s يعرض التعادل. هل توافق؟", "%s offers a draw. Accept?") % who
	open_dialog(title, msg, [
		[Games.L("قبول", "Accept"), Color("2ed573"), respond.bind(true)],
		[Games.L("رفض", "Decline"), Color("ff4757"), respond.bind(false)]
	])

# ------------------------------------------------------------------
#  الواجهة: الأزرار، السجل، النافذة، الرسائل
# ------------------------------------------------------------------
func action_btn(text: String, c: Color, icon: String) -> Button:
	var b = Games.btn(text, c, 88, 34)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var a = Control.new()
	a.set_script(load("res://art.gd"))
	a.set("kind", icon)
	a.set("col", Color.WHITE)
	a.anchor_left = 0.0
	a.anchor_right = 0.0
	a.anchor_top = 0.0
	a.anchor_bottom = 1.0
	a.offset_left = 14.0
	a.offset_right = 74.0
	a.offset_top = 12.0
	a.offset_bottom = -12.0
	b.add_child(a)
	return b

func legend() -> HFlowContainer:
	var h = HFlowContainer.new()
	h.add_theme_constant_override("h_separation", 14)
	h.add_theme_constant_override("v_separation", 4)
	for o in order:
		var dot = Panel.new()
		dot.custom_minimum_size = Vector2(22, 22)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.add_theme_stylebox_override("panel", Games.style(pcol(o), 11, 2))
		h.add_child(dot)
		var l = Label.new()
		var tag = ""
		if online:
			if o == order[my_seat]:
				tag = " (" + Games.L("أنت", "You") + ")"
			elif two:
				tag = " (" + Games.L("الخصم", "Opponent") + ")"
		l.text = cname(o) + tag
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.add_theme_font_size_override("font_size", 24)
		l.add_theme_color_override("font_color", TC2[o] if two else TC4[o])
		h.add_child(l)
	return h

func build_ui() -> void:
	ui = VBoxContainer.new()
	ui.set_anchors_preset(PRESET_BOTTOM_WIDE)
	ui.offset_left = 10.0
	ui.offset_right = -10.0
	ui.offset_top = -UI_H
	ui.offset_bottom = -8.0
	ui.add_theme_constant_override("separation", 8)
	body.add_child(ui)
	# لوحة سجل النقلات
	var lp = PanelContainer.new()
	lp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lp.custom_minimum_size = Vector2(0, 100)
	var sb = Games.flat(Color(0, 0, 0, 0.4), 26)
	sb.set_content_margin_all(12)
	lp.add_theme_stylebox_override("panel", sb)
	ui.add_child(lp)
	var lv = VBoxContainer.new()
	lv.add_theme_constant_override("separation", 6)
	lp.add_child(lv)
	lv.add_child(legend())
	log_sc = ScrollContainer.new()
	log_sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lv.add_child(log_sc)
	log_box = HFlowContainer.new()
	log_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_box.add_theme_constant_override("h_separation", 8)
	log_box.add_theme_constant_override("v_separation", 8)
	log_sc.add_child(log_box)
	# الأزرار
	btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	ui.add_child(btn_row)
	btn_undo = action_btn(Games.L("تراجع", "Undo"), Color("f39c12"), "undo")
	btn_undo.pressed.connect(on_undo)
	btn_row.add_child(btn_undo)
	btn_draw = action_btn(Games.L("عرض تعادل", "Offer draw"), Color("3498db"), "draw")
	btn_draw.pressed.connect(on_draw)
	btn_draw.visible = two
	btn_row.add_child(btn_draw)
	update_buttons()

func update_buttons() -> void:
	if btn_undo == null:
		return
	var busy = over or pending != null
	var can = (not busy) and (not history.is_empty())
	if can and online:
		can = last_index(order[my_seat]) >= 0
	btn_undo.disabled = not can
	btn_draw.disabled = busy
	btn_row.visible = not over
	# عند نهاية اللعبة نرفع اللوحة حتى لا يغطيها زر "اللعبة التالية"
	ui.offset_bottom = -186.0 if over else -8.0

func close_dialog() -> void:
	if dlg != null and is_instance_valid(dlg):
		dlg.queue_free()
	dlg = null

func open_dialog(title: String, msg: String, btns: Array) -> void:
	close_dialog()
	dlg = Control.new()
	dlg.set_anchors_preset(PRESET_FULL_RECT)
	dlg.offset_top = st + 110
	dlg.z_index = 60
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.set_anchors_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dlg.add_child(dim)
	var cc = CenterContainer.new()
	cc.set_anchors_preset(PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dlg.add_child(cc)
	var pn = PanelContainer.new()
	pn.custom_minimum_size = Vector2(620, 0)
	var sb = Games.style(Color("2a2f45"), 36, 8)
	sb.set_content_margin_all(28)
	pn.add_theme_stylebox_override("panel", sb)
	cc.add_child(pn)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 22)
	pn.add_child(v)
	var tl = big_label(title, 46, Color.GOLD)
	tl.custom_minimum_size = Vector2(560, 0)
	v.add_child(tl)
	var ml = big_label(msg, 32, Color.WHITE)
	ml.custom_minimum_size = Vector2(560, 0)
	v.add_child(ml)
	var hb = HBoxContainer.new()
	hb.add_theme_constant_override("separation", 18)
	v.add_child(hb)
	for b in btns:
		var bt = Games.btn(b[0], b[1], 96, 38)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bt.pressed.connect(b[2])
		hb.add_child(bt)
	add_child(dlg)
	Games.pop(pn)

func toast(t: String, c: Color) -> void:
	if toast_node != null and is_instance_valid(toast_node):
		toast_node.queue_free()
	var holder = VBoxContainer.new()
	holder.set_anchors_preset(PRESET_FULL_RECT)
	holder.offset_top = st + 130
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = 70
	var pn = PanelContainer.new()
	pn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var sb = Games.style(c.darkened(0.35), 30, 6)
	sb.set_content_margin_all(18)
	pn.add_theme_stylebox_override("panel", sb)
	var l = big_label(t, 34, Color.WHITE)
	l.custom_minimum_size = Vector2(520, 0)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pn.add_child(l)
	holder.add_child(pn)
	add_child(holder)
	toast_node = holder
	var tw = create_tween()
	tw.tween_interval(2.4)
	tw.tween_property(holder, "modulate:a", 0.0, 0.4)
	tw.tween_callback(holder.queue_free)

# ------------------------------------------------------------------
#  تنفيذ النقلة
# ------------------------------------------------------------------
func do_move(a: Vector2i, b: Vector2i, ptype: String = "") -> void:
	var snap = take_snap()
	var pc = board[a]
	var o = pc[0]
	var first = not pc[2]
	var piece_t = pc[1]
	var castle_side = 0
	var promo_t = ""
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
		castle_side = step
	eps = eps.filter(func(en): return en[2] != o)
	if pc[1] == "P" and (a.x == b.x or a.y == b.y) and absi(b.x - a.x) + absi(b.y - a.y) == 2:
		eps.append([Vector2i((a.x + b.x) / 2, (a.y + b.y) / 2), b, o])
	if pc[1] == "P" and rank_index(b, o) == 7:
		pc[1] = ptype if (two and ptype != "") else "Q"
		pc[3] = true
		promo_t = pc[1]
	board[b] = pc
	var was_cap = cap != null
	if cap != null and not dead.has(cap[0]) and not two:
		points[o] += 1 if cap[3] else VAL[cap[1]]
	lastmv = [a, b]
	sel = null
	legal_moves = []
	checked = []
	anim = [a, b, 0.0]
	if anim_tw != null:
		anim_tw.kill()
	anim_tw = create_tween()
	anim_tw.tween_method(set_anim, 0.0, 1.0, 0.2)
	anim_tw.finished.connect(end_anim)
	if cap != null:
		Sound.tone(200, 0.2, 1)
	else:
		Sound.tone(520, 0.08, 2)
	if two:
		two_after(o)
	else:
		multi_after(o, b)
	# تسجيل النقلة في السجل
	var suffix = ""
	if not checked.is_empty():
		suffix = "#" if (two and over) else "+"
	history.append({"o": o, "san": make_san(piece_t, a, b, was_cap, castle_side, promo_t) + suffix, "snap": snap})
	add_chip(history.size() - 1)
	scroll_log()
	update_buttons()
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
	var avail = body.size.y - UI_H - 8.0
	cell = minf((body.size.x - m * 2.0) / S, (avail - m * 2.0) / S)
	ox = (body.size.x - cell * S) / 2.0
	oy = (avail - cell * S) / 2.0
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
	if anim != null and board.has(anim[1]):
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
			var ink_c = Color.BLACK if (o == 2 and not dead.has(o)) else Color.WHITE
			body.draw_string(f, r.position + Vector2(8, cell * 0.8), cname(o), HORIZONTAL_ALIGNMENT_LEFT, cell * 2.8, int(cell * 0.4), ink_c)
			body.draw_string(f, r.position + Vector2(8, cell * 2.1), str(points[o]), HORIZONTAL_ALIGNMENT_LEFT, cell * 2.8, int(cell * 0.95), ink_c)
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
