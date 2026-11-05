extends "res://zones.gd"
const ROUNDS = 5
var sc = []
var phase = "idle"
var rnd = 0
var rid = 0
var t0 = 0

func build() -> void:
	make_zones(players)
	for i in players:
		sc.append(0)
	labels()
	start_round()

func labels() -> void:
	for i in players:
		lab[i].text = "%s\n%d" % [Games.PN[i], sc[i]]
		lab[i].add_theme_font_size_override("font_size", 56)

func tint_all(c: Color) -> void:
	for p in pan:
		if p != null:
			paint_zone(p, c)

func start_round() -> void:
	rid += 1
	var my = rid
	phase = "wait"
	tint_all(Color("636e72"))
	say(Games.L("انتظر اللون الأخضر...", "Wait for green..."), Color.WHITE)
	if not await wait(randf_range(1.5, 4.0)):
		return
	if phase != "wait" or my != rid:
		return
	phase = "go"
	tint_all(Color("00b894"))
	say(Games.L("اضغط الآن!!", "TAP NOW!!"), Color("00b894"))
	Sound.tone(880, 0.2, 2)
	t0 = Time.get_ticks_msec()

func on_zone_press(s: int, pt: Vector2) -> void:
	if over:
		return
	if phase == "wait" or phase == "go":
		press_fx(s, pt)
		tap(s)

func tap(i: int) -> void:
	if phase == "wait":
		phase = "between"
		sc[i] -= 1
		paint_zone(pan[i], Color("d63031"))
		say("%s %s" % [Games.PN[i], Games.L("استعجل! -1", "too early! -1")], Color("ff7675"))
		Sound.lose()
		after_round()
	elif phase == "go":
		phase = "between"
		sc[i] += 1
		var ms = Time.get_ticks_msec() - t0
		paint_zone(pan[i], col(i))
		say("%s - %d ms" % [Games.PN[i], ms], col(i))
		Sound.tone(1000, 0.15, 2)
		pulse(lab[i])
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
			finish(Games.L("نقاطك: %d من %d" % [sc[0], ROUNDS], "Your points: %d of %d" % [sc[0], ROUNDS]))
		elif sc.count(sc[best]) > 1:
			finish("تعادل", Color.WHITE)
		else:
			dim_others(best)
			finish("فاز " + Games.PN[best], col(best))
	else:
		start_round()
