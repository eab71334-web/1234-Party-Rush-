extends "res://base.gd"
var q: Label
var disp: Label
var cur = ""
var ans = 0
var scores = []
var asked = 0
var total = 10

func build() -> void:
	total = 10 if players == 1 else players * 5
	for i in players:
		scores.append(0)
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 20)
	body.add_child(v)
	q = big_label("", 100, Color.WHITE)
	v.add_child(q)
	disp = big_label("؟", 90, Color.GOLD)
	v.add_child(disp)
	spacer(v)
	v.add_child(pad(key))
	newq()
	refresh()

func newq() -> void:
	var a = randi_range(2, 12)
	var b = randi_range(2, 12)
	match randi() % 3:
		0:
			q.text = "%d + %d" % [a, b]
			ans = a + b
		1:
			q.text = "%d - %d" % [a + b, b]
			ans = a
		_:
			a = randi_range(2, 9)
			b = randi_range(2, 9)
			q.text = "%d × %d" % [a, b]
			ans = a * b

func refresh() -> void:
	if players == 1:
		say("➕ السؤال %d/%d  ✅ %d" % [asked + 1, total, scores[0]])
	else:
		say("دور %s   ✅ %d" % [Games.PN[turn], scores[turn]], col(turn))

func key(k: String) -> void:
	if over:
		return
	if k == "حذف":
		cur = cur.substr(0, cur.length() - 1)
	elif k == "تم":
		submit()
		return
	elif cur.length() < 4:
		cur += k
	disp.text = cur if cur != "" else "؟"

func submit() -> void:
	if cur == "":
		return
	if int(cur) == ans:
		scores[turn] += 1
		Sound.tone(900, 0.15, 2)
	else:
		Sound.lose()
	cur = ""
	disp.text = "؟"
	asked += 1
	if asked >= total:
		var best = 0
		for i in players:
			if scores[i] > scores[best]:
				best = i
		if players == 1:
			finish("🏁 نتيجتك %d من %d" % [scores[0], total])
		elif scores.count(scores[best]) > 1:
			finish("🤝 تعادل", Color.WHITE)
		else:
			finish("🏆 فاز " + Games.PN[best], col(best))
		return
	if players > 1:
		turn = (turn + 1) % players
	newq()
	refresh()
