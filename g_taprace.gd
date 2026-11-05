extends "res://zones.gd"
const GOAL = 25
var score = []
var t0 = 0
var go = false

func build() -> void:
	make_zones(players)
	for i in players:
		score.append(0)
		lab[i].text = ""
	say(Games.L("اضغط مساحتك بسرعة! الهدف %d" % GOAL, "Tap your zone fast! Goal %d" % GOAL), Color.WHITE)
	countdown()

func countdown() -> void:
	for n in [3, 2, 1]:
		for i in players:
			lab[i].text = str(n)
			pulse(lab[i])
		Sound.tone(400 + n * 80, 0.12, 2)
		if not await wait(0.8):
			return
	go = true
	t0 = Time.get_ticks_msec()
	Sound.tone(1000, 0.25, 2)
	for i in players:
		lab[i].text = Games.L("انطلق!", "GO!")
		pulse(lab[i])
	if not await wait(0.5):
		return
	for i in players:
		if score[i] == 0:
			lab[i].text = "0"

func on_zone_press(s: int, pt: Vector2) -> void:
	if over or not go:
		return
	press_fx(s, pt)
	tap(s)

func tap(i: int) -> void:
	score[i] += 1
	lab[i].text = str(score[i])
	pulse(lab[i])
	set_progress(i, score[i] / float(GOAL))
	Sound.tone(400 + score[i] * 15, 0.05, 2, -10.0)
	if score[i] >= GOAL:
		var secs = (Time.get_ticks_msec() - t0) / 1000.0
		if players == 1:
			finish(Games.L("خلصت في %.1f ثانية" % secs, "Finished in %.1f s" % secs))
		else:
			dim_others(i)
			finish("فاز " + Games.PN[i], col(i))
