extends "res://base.gd"
var secret = 0
var cur = ""
var disp: Label
var hint: Label
var hist: Label
var lo = 1
var hi = 100
var tries = 0
var log_t = []

func build() -> void:
	secret = randi_range(1, 100)
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 20)
	body.add_child(v)
	hint = big_label(Games.L("خمّن رقم من 1 إلى 100", "Guess a number from 1 to 100"), 40)
	hint.custom_minimum_size = Vector2(0, 150)
	v.add_child(hint)
	hist = big_label("", 28, Color(1, 1, 1, 0.7))
	hist.custom_minimum_size = Vector2(0, 70)
	v.add_child(hist)
	disp = big_label("؟", 110, Color.GOLD)
	v.add_child(disp)
	spacer(v)
	v.add_child(pad(key))
	show_turn()

func key(k: String) -> void:
	if over:
		return
	if k == "حذف":
		cur = cur.substr(0, cur.length() - 1)
	elif k == "تم":
		submit()
		return
	elif cur.length() < 3:
		cur += k
	disp.text = cur if cur != "" else "؟"

func submit() -> void:
	if cur == "":
		return
	var n = int(cur)
	cur = ""
	disp.text = "؟"
	tries += 1
	if n == secret:
		finish("🎯 %s خمّن الرقم %d" % [Games.PN[turn], secret], col(turn))
		return
	Sound.tone(250, 0.15, 1)
	if n < secret:
		lo = maxi(lo, n + 1)
	else:
		hi = mini(hi, n - 1)
	log_t.append(str(n))
	if log_t.size() > 8:
		log_t.pop_front()
	var dir = Games.L("أكبر", "higher") if n < secret else Games.L("أصغر", "lower")
	hint.text = Games.L("%d ← الرقم %s\nالمدى: %d - %d" % [n, dir, lo, hi], "%d - the number is %s\nRange: %d - %d" % [n, dir, lo, hi])
	hist.text = Games.L("المحاولات: ", "Tries: ") + ", ".join(log_t)
	disp.pivot_offset = disp.size / 2.0
	disp.scale = Vector2(0.8, 0.8)
	create_tween().tween_property(disp, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if players > 1:
		next_turn()
