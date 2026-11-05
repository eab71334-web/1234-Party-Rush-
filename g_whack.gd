extends "res://base.gd"
var holes = []
var moles = []
var up = -1
var score = 0
var combo = 0
var left = 30.0
var hit_now = false
var last_i = -1

func build() -> void:
	var g = center_grid(3, 16)
	for i in 9:
		var b = Games.btn("", Color("7b5230"), 210, 100)
		b.custom_minimum_size = Vector2(210, 210)
		b.pressed.connect(hit.bind(i))
		var a = Control.new()
		a.set_script(load("res://art.gd"))
		a.set("kind", "mole")
		a.set_anchors_preset(Control.PRESET_FULL_RECT)
		a.visible = false
		b.add_child(a)
		g.add_child(b)
		holes.append(b)
		moles.append(a)
		Games.pop(b, i * 0.03)
	loop()

func bump(b: Control) -> void:
	b.pivot_offset = b.size / 2.0
	b.scale = Vector2(0.9, 0.9)
	create_tween().tween_property(b, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hit(i: int) -> void:
	if over:
		return
	if i == up and not hit_now:
		hit_now = true
		combo += 1
		score += 1 + (1 if combo >= 5 else 0)
		moles[i].set("kind", "boom")
		moles[i].queue_redraw()
		bump(holes[i])
		Sound.tone(700 + score * 10, 0.08, 2)
	else:
		combo = 0
		Sound.tone(150, 0.1, 1)

func loop() -> void:
	if not await wait(0.8):
		return
	while not over:
		var i = randi() % 9
		if i == last_i:
			i = (i + 1 + randi() % 8) % 9
		last_i = i
		up = i
		hit_now = false
		var m = moles[i]
		m.set("kind", "mole")
		m.visible = true
		m.pivot_offset = m.size / 2.0
		m.scale = Vector2(0.3, 0.3)
		create_tween().tween_property(m, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var limit = maxf(0.4, 0.95 - score * 0.02)
		var el = 0.0
		while el < limit and not hit_now and not over:
			if not await wait(0.03):
				return
			el += 0.03
		if over:
			return
		if hit_now:
			if not await wait(0.18):
				return
		else:
			combo = 0
		m.visible = false
		up = -1
		if not await wait(0.12):
			return

func _process(d: float) -> void:
	super._process(d)
	if over:
		return
	left -= d
	say("%d    %d    x%d" % [ceili(maxf(left, 0.0)), score, combo])
	if left <= 0.0:
		up = -1
		finish("%s: %d" % [Games.L("نتيجتك", "Your score"), score])
