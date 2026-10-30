extends "res://base.gd"
var holes = []
var moles = []
var up = -1
var score = 0
var left = 30.0

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

func hit(i: int) -> void:
	if over:
		return
	if i == up:
		score += 1
		up = -1
		moles[i].set("kind", "boom")
		moles[i].queue_redraw()
		Sound.tone(700 + score * 10, 0.08, 2)
	else:
		Sound.tone(150, 0.1, 1)

func loop() -> void:
	while not over:
		var i = randi() % 9
		up = i
		moles[i].set("kind", "mole")
		moles[i].visible = true
		if not await wait(maxf(0.4, 0.9 - score * 0.02)):
			return
		moles[i].visible = false
		up = -1
		if not await wait(0.15):
			return

func _process(d: float) -> void:
	if over:
		return
	left -= d
	say("%d    %d" % [ceili(left), score])
	if left <= 0.0:
		finish("%s: %d" % [Games.L("نتيجتك", "Your score"), score])
