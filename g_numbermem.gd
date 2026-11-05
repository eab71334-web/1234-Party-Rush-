extends "res://race.gd"
var level = 3
var shown = ""
var cur_in = ""
var lives = 3
var label: Label
var entry: Label
var info_l: Label
var bar: ProgressBar
var accept = false

func setup() -> void:
	time_left = 60.0
	info_l = big_label("", 28, Color(1, 1, 1, 0.75))
	info_l.set_anchors_preset(PRESET_TOP_WIDE)
	info_l.offset_top = 0
	info_l.offset_bottom = 40
	area.add_child(info_l)
	label = big_label("", 110)
	label.set_anchors_preset(PRESET_TOP_WIDE)
	label.offset_top = 40
	label.offset_bottom = 210
	area.add_child(label)
	bar = ProgressBar.new()
	bar.set_anchors_preset(PRESET_TOP_WIDE)
	bar.offset_top = 214
	bar.offset_bottom = 226
	bar.offset_left = 60
	bar.offset_right = -60
	bar.max_value = 1.0
	bar.value = 0.0
	bar.show_percentage = false
	bar.add_theme_stylebox_override("fill", Games.flat(Color("ffd32a"), 6))
	bar.add_theme_stylebox_override("background", Games.flat(Color(1, 1, 1, 0.12), 6))
	area.add_child(bar)
	entry = big_label("", 90, Color.GOLD)
	entry.set_anchors_preset(PRESET_TOP_WIDE)
	entry.offset_top = 236
	entry.offset_bottom = 400
	area.add_child(entry)
	var p = pad(key)
	p.set_anchors_preset(PRESET_BOTTOM_WIDE)
	p.offset_top = -460
	p.offset_bottom = -10
	area.add_child(p)

func hint_text() -> String:
	return Games.L("احفظ الرقم ثم اكتبه", "Memorize the number, then type it")

func begin() -> void:
	new_round()

func refresh_info() -> void:
	info_l.text = "%s %d     %s: %d" % [Games.L("المستوى", "Level"), level - 2, Games.L("الأرواح", "Lives"), lives]

func new_round() -> void:
	accept = false
	shown = ""
	for i in level:
		shown += str(rng.randi() % 10)
	label.text = shown
	label.add_theme_color_override("font_color", Color.WHITE)
	entry.text = ""
	cur_in = ""
	refresh_info()
	var t = 0.5 + level * 0.3
	bar.value = 1.0
	create_tween().tween_property(bar, "value", 0.0, t)
	if not await wait(t):
		return
	label.text = "?"
	accept = true

func key(k: String) -> void:
	if not accept or not running:
		return
	if k == "حذف":
		cur_in = cur_in.substr(0, cur_in.length() - 1)
	elif k == "تم":
		accept = false
		if cur_in == shown:
			add(level)
			Sound.tone(900, 0.15, 2)
			entry.add_theme_color_override("font_color", Color("2ed573"))
			level += 1
			if not await wait(0.25):
				return
		else:
			lives -= 1
			Sound.lose()
			entry.add_theme_color_override("font_color", Color("ff4757"))
			label.text = shown
			label.add_theme_color_override("font_color", Color("2ed573"))
			refresh_info()
			if lives <= 0:
				end_round()
				return
			if not await wait(0.9):
				return
		entry.add_theme_color_override("font_color", Color.GOLD)
		new_round()
		return
	elif cur_in.length() < level:
		cur_in += k
	entry.text = cur_in
