extends "res://base.gd"
const ROUNDS = 5
var bands = []
var sc = []
var phase = "idle"
var rnd = 0
var rid = 0
var t0 = 0

func build() -> void:
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 14)
	body.add_child(v)
	for i in players:
		sc.append(0)
		var b = Games.btn("", Color("636e72"), 100, 52)
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.button_down.connect(tap.bind(i))
		v.add_child(b)
		bands.append(b)
	labels()
	start_round()

func labels() -> void:
	for i in players:
		bands[i].text = "%s : %d" % [Games.PN[i], sc[i]]

func tint_all(c: Color) -> void:
	for b in bands:
		Games.tint(b, c)

func start_round() -> void:
	rid += 1
	var my = rid
	phase = "wait"
	tint_all(Color("636e72"))
	say("🚦 انتظر اللون الأخضر...")
	if not await wait(randf_range(1.5, 4.0)):
		return
	if phase != "wait" or my != rid:
		return
	phase = "go"
	tint_all(Color("00b894"))
	say("اضغط الآن!!", Color("00b894"))
	Sound.tone(880, 0.2, 2)
	t0 = Time.get_ticks_msec()

func tap(i: int) -> void:
	if over:
		return
	if phase == "wait":
		phase = "between"
		sc[i] -= 1
		Games.tint(bands[i], Color("d63031"))
		say("%s استعجل! -1" % Games.PN[i], Color("ff7675"))
		Sound.lose()
		after_round()
	elif phase == "go":
		phase = "between"
		sc[i] += 1
		var ms = Time.get_ticks_msec() - t0
		Games.tint(bands[i], col(i))
		say("%s — %d ms" % [Games.PN[i], ms], col(i))
		Sound.tone(1000, 0.15, 2)
		after_round()

func after_round() -> void:
	rnd += 1
	labels()
	if not await wait(1.4):
		return
	if rnd >= ROUNDS:
		var best = 0
		for i in players:
			if sc[i] > sc[best]:
				best = i
		if players == 1:
			finish("🏁 نقاطك: %d من %d" % [sc[0], ROUNDS])
		elif sc.count(sc[best]) > 1:
			finish("🤝 تعادل", Color.WHITE)
		else:
			finish("🏆 فاز " + Games.PN[best], col(best))
	else:
		start_round()
