extends "res://base.gd"
const QTIME = 10.0
var q: Label
var disp: Label
var bar: ProgressBar
var cur = ""
var ans = 0
var scores = []
var asked = 0
var total = 10
var qt = QTIME

func build() -> void:
	total = 10 if players == 1 else players * 5
	for i in players:
		scores.append(0)
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 20)
	body.add_child(v)
	bar = ProgressBar.new()
	bar.max_value = QTIME
	bar.value = QTIME
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 30)
	bar.add_theme_stylebox_override("fill", Games.flat(Color("2ed573"), 14))
	bar.add_theme_stylebox_override("background", Games.flat(Color(1, 1, 1, 0.12), 14))
	v.add_child(bar)
	q = big_label("", 100, Color.WHITE)
	v.add_child(q)
	disp = big_label("؟", 90, Color.GOLD)
	v.add_child(disp)
	spacer(v)
	v.add_child(pad(key))
	newq()
	refresh()

func _process(d: float) -> void:
	super._process(d)
	if over:
		return
	qt -= d
	bar.value = maxf(qt, 0.0)
	bar.add_theme_stylebox_override("fill", Games.flat(Color("2ed573") if qt > 3.0 else Color("ff4757"), 14))
	if qt <= 0.0:
		resolve(false)

func newq() -> void:
	qt = QTIME
	var a = randi_range(2, 12)
	var b = randi_range(2, 12)
	match randi() % 4:
		0:
			q.text = "%d + %d" % [a, b]
			ans = a + b
		1:
			q.text = "%d - %d" % [a + b, b]
			ans = a
		2:
			a = randi_range(2, 9)
			b = randi_range(2, 9)
			q.text = "%d × %d" % [a, b]
			ans = a * b
		_:
			b = randi_range(2, 9)
			a = b * randi_range(2, 9)
			q.text = "%d ÷ %d" % [a, b]
			ans = a / b

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
		if cur != "":
			resolve(int(cur) == ans)
		return
	elif cur.length() < 4:
		cur += k
	disp.text = cur if cur != "" else "؟"

func resolve(correct: bool) -> void:
	if over:
		return
	if correct:
		scores[turn] += 1
		Sound.tone(900, 0.15, 2)
		disp.modulate = Color("2ed573")
	else:
		Sound.lose()
		disp.modulate = Color("ff4757")
	create_tween().tween_property(disp, "modulate", Color.WHITE, 0.4)
	cur = ""
	disp.text = "؟"
	asked += 1
	qt = QTIME
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
