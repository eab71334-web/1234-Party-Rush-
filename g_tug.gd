extends "res://zones.gd"
var p = 0.5
var shown = 0.5
var tops = []
var lows = []
var top_box: HBoxContainer
var low_box: HBoxContainer
var seats = 2
var bot_seat = -1
var bot_t2 = 0.0

func team_top(s: int) -> bool:
	return s % 2 == 1

func build() -> void:
	seats = 2 if players == 1 else players
	if players == 1:
		bot_seat = 1
	var v = VBoxContainer.new()
	v.set_anchors_preset(PRESET_FULL_RECT)
	v.add_theme_constant_override("separation", 10)
	body.add_child(v)
	top_box = HBoxContainer.new()
	top_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_box.add_theme_constant_override("separation", 10)
	low_box = HBoxContainer.new()
	low_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	low_box.add_theme_constant_override("separation", 10)
	v.add_child(top_box)
	v.add_child(low_box)
	for s in seats:
		var top = team_top(s)
		var z = make_zone(s, top)
		z[1].text = Games.L("اضغط!", "TAP!")
		z[1].add_theme_font_size_override("font_size", 70)
		(top_box if top else low_box).add_child(z[0])
		pan.append(z[0])
		lab.append(z[1])
		if top:
			tops.append(s)
		else:
			lows.append(s)
	say(Games.L("شدّ الحبل! لكل لاعب مساحته", "Tug of war! Each player has a zone"), Color.WHITE)

func _process(d: float) -> void:
	super._process(d)
	if not over and bot_seat >= 0:
		bot_t2 += d
		if bot_t2 >= 0.22:
			bot_t2 = 0.0
			press_flash(bot_seat)
			pull(bot_seat)
	shown = lerpf(shown, p, 1.0 - exp(-d * 14.0))
	top_box.size_flags_stretch_ratio = maxf(shown, 0.02)
	low_box.size_flags_stretch_ratio = maxf(1.0 - shown, 0.02)

func on_zone_press(s: int, pt: Vector2) -> void:
	if over or s == bot_seat:
		return
	press_fx(s, pt)
	pull(s)

func pull(s: int) -> void:
	if over:
		return
	var top = team_top(s)
	var n = tops.size() if top else lows.size()
	var power = 0.04 / maxf(n, 1)
	p += power if top else -power
	Sound.tone(300 + (150 if top else 0), 0.04, 2, -12.0)
	pulse(lab[s])
	if p >= 0.94:
		end_tug(true)
	elif p <= 0.06:
		end_tug(false)

func end_tug(top_wins: bool) -> void:
	for s in seats:
		if team_top(s) != top_wins:
			pan[s].modulate = Color(0.55, 0.55, 0.55)
	if top_wins:
		finish(Games.L("فاز الفريق العلوي", "Top team wins"), col(tops[0]))
	else:
		finish(Games.L("فاز الفريق السفلي", "Bottom team wins"), col(lows[0]))
