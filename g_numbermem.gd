extends "res://race.gd"
var level = 3
var shown = ""
var cur_in = ""
var lives = 3
var label: Label
var entry: Label
var accept = false

func setup() -> void:
	time_left = 60.0
	label = big_label("", 110)
	label.set_anchors_preset(PRESET_TOP_WIDE)
	label.offset_top = 20
	label.offset_bottom = 220
	area.add_child(label)
	entry = big_label("", 90, Color.GOLD)
	entry.set_anchors_preset(PRESET_TOP_WIDE)
	entry.offset_top = 230
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

func new_round() -> void:
	accept = false
	shown = ""
	for i in level:
		shown += str(rng.randi() % 10)
	label.text = shown
	entry.text = ""
	cur_in = ""
	if not await wait(0.5 + level * 0.3):
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
			level += 1
		else:
			lives -= 1
			Sound.lose()
			if lives <= 0:
				end_round()
				return
		new_round()
		return
	elif cur_in.length() < level:
		cur_in += k
	entry.text = cur_in
