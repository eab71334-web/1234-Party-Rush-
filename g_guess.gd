extends "res://base.gd"
var secret = 0
var cur = ""
var disp: Label
var hint: Label

func build() -> void:
	secret = randi_range(1, 100)
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 20)
	body.add_child(v)
	hint = big_label("خمّن رقم من 1 إلى 100", 40)
	hint.custom_minimum_size = Vector2(0, 120)
	v.add_child(hint)
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
	if n == secret:
		finish("🎯 %s خمّن الرقم %d" % [Games.PN[turn], secret], col(turn))
		return
	Sound.tone(250, 0.15, 1)
	hint.text = "%d ← الرقم %s" % [n, "أكبر ⬆" if n < secret else "أصغر ⬇"]
	if players > 1:
		next_turn()
