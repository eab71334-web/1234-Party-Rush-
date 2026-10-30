extends "res://race.gd"
var rounds = 0
var phase = 0
var t0 = 0
var total = 0
var panel: Button

func setup() -> void:
	time_left = 90.0
	lower_wins = true
	panel = Games.btn("", Color("636e72"), 300, 70)
	panel.set_anchors_preset(PRESET_FULL_RECT)
	panel.offset_top = 60
	panel.offset_bottom = -40
	panel.offset_left = 20
	panel.offset_right = -20
	panel.button_down.connect(tap)
	area.add_child(panel)

func hint_text() -> String:
	return Games.L("اضغط لما يصير أخضر - الأقل وقتاً يفوز", "Tap on green - lowest time wins")

func begin() -> void:
	start_round()

func add_none() -> void:
	pass

func start_round() -> void:
	phase = 1
	Games.tint(panel, Color("d63031"))
	panel.text = Games.L("انتظر...", "Wait...")
	if not await wait(rng.randf_range(1.2, 3.5)):
		return
	if phase != 1:
		return
	phase = 2
	Games.tint(panel, Color("00b894"))
	panel.text = Games.L("الآن!", "NOW!")
	Sound.tone(900, 0.15, 2)
	t0 = Time.get_ticks_msec()

func tap() -> void:
	if not running:
		return
	if phase == 1:
		total += 500
		phase = 3
		panel.text = Games.L("بدري! +500", "Too early! +500")
		Sound.lose()
	elif phase == 2:
		var ms = Time.get_ticks_msec() - t0
		total += ms
		phase = 3
		panel.text = "%d ms" % ms
	else:
		return
	rounds += 1
	score = total
	if rounds >= 5:
		pills[my_seat if online else 0].text = str(total)
		if not await wait(0.8):
			return
		end_round()
	else:
		if not await wait(0.9):
			return
		start_round()
