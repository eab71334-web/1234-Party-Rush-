extends "res://base.gd"
# إطار ألعاب السباق: الكل يلعب نفس التحدي (نفس البذرة) والأعلى نقاطاً يفوز
var DURATION = 30.0
var score = 0
var time_left = 30.0
var running = false
var lower_wins = false
var area: Control
var cd: Label
var pills = []
var sent_score = -999999
var send_t = 0.0
var final_sent = false
var decided = false

func build() -> void:
	area = Control.new()
	area.set_anchors_preset(PRESET_FULL_RECT)
	area.offset_top = 96
	area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(area)
	var hb = HBoxContainer.new()
	hb.set_anchors_preset(PRESET_TOP_WIDE)
	hb.offset_bottom = 84
	hb.add_theme_constant_override("separation", 10)
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(hb)
	for i in players:
		var p = Label.new()
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		p.add_theme_font_size_override("font_size", 30)
		p.add_theme_stylebox_override("normal", Games.flat(col(i).darkened(0.25 if i != my_seat else 0.0), 24))
		p.text = "0"
		hb.add_child(p)
		pills.append(p)
	if online:
		Net.scores_changed.connect(_scores)
	cd = Label.new()
	cd.set_anchors_preset(PRESET_FULL_RECT)
	cd.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cd.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cd.add_theme_font_size_override("font_size", 200)
	cd.add_theme_color_override("font_outline_color", Color.BLACK)
	cd.add_theme_constant_override("outline_size", 18)
	cd.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cd.z_index = 50
	area.add_child(cd)
	time_left = DURATION
	setup()
	countdown()

func setup() -> void:
	pass

func begin() -> void:
	pass

func tick(_d: float) -> void:
	pass

func hint_text() -> String:
	return ""

func countdown() -> void:
	say(hint_text())
	for n in [3, 2, 1]:
		cd.text = str(n)
		Sound.tone(400 + n * 80, 0.12, 2)
		if not await wait(0.8):
			return
	cd.text = Games.L("انطلق!", "GO!")
	Sound.tone(1000, 0.25, 2)
	running = true
	begin()
	if not await wait(0.5):
		return
	cd.text = ""

func add(n: int) -> void:
	if not running:
		return
	score += n
	pills[my_seat if online else 0].text = str(score)

func _process(d: float) -> void:
	super._process(d)
	if not running:
		return
	time_left -= d
	tick(d)
	say("%d     %d" % [ceili(maxf(time_left, 0.0)), score], col(my_seat))
	send_t += d
	if online and send_t > 0.3 and score != sent_score:
		send_t = 0.0
		sent_score = score
		Net.report(score, false)
	if time_left <= 0.0:
		end_round()

func end_round() -> void:
	if not running:
		return
	running = false
	on_end()
	say(Games.L("انتظار الباقين...", "Waiting for others..."), Color.WHITE)
	if online:
		Net.report(score, true)
	else:
		finish("%s: %d" % [Games.L("نتيجتك", "Your score"), score])

func on_end() -> void:
	pass

func on_abort() -> void:
	running = false
	decided = true

func _scores(sc: Dictionary, dn: Dictionary) -> void:
	for s in sc.keys():
		if s < pills.size():
			pills[s].text = str(sc[s])
	if decided or dn.size() < players:
		return
	decided = true
	var best = -1
	var bv = 0
	var tie = false
	for s in sc.keys():
		var v = sc[s]
		if best < 0 or (v < bv if lower_wins else v > bv):
			best = s
			bv = v
			tie = false
		elif v == bv:
			tie = true
	if tie:
		finish(Games.L("تعادل", "Draw") + " (%d)" % bv, Color.WHITE)
	else:
		finish("فاز " + Games.PN[best] + "  (%d)" % bv, col(best))
