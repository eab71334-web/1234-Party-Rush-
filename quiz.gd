extends "res://race.gd"
# إطار أسئلة الاختيار: next_q() تضبط prompt و opts و ans
var prompt: Label
var optb = []
var ans = 0
var NOPTS = 4
var COLS = 2
var PENALTY = 1
var cooldown = false
var streak = 0

func setup() -> void:
	prompt = Label.new()
	prompt.set_anchors_preset(PRESET_TOP_WIDE)
	prompt.offset_top = 40
	prompt.offset_bottom = 420
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 130)
	prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	prompt.add_theme_constant_override("outline_size", 12)
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(prompt)
	var g = GridContainer.new()
	g.columns = COLS
	g.set_anchors_preset(PRESET_BOTTOM_WIDE)
	g.offset_top = -(300 if NOPTS > 2 else 160) - 20
	g.offset_bottom = -20
	g.add_theme_constant_override("h_separation", 16)
	g.add_theme_constant_override("v_separation", 16)
	area.add_child(g)
	for i in NOPTS:
		var b = Games.btn("", col(i), 130, 60)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_EXPAND_FILL
		b.button_down.connect(choose.bind(i))
		g.add_child(b)
		optb.append(b)
	next_q()

func begin() -> void:
	pass

func next_q() -> void:
	pass

func set_opt(i: int, t: String, c: Color = Color("6c5ce7")) -> void:
	optb[i].text = Games.tx(t)
	Games.tint(optb[i], c)

func flash_opt(i: int, c: Color) -> void:
	if i < 0 or i >= optb.size():
		return
	var b = optb[i]
	b.modulate = c
	create_tween().tween_property(b, "modulate", Color.WHITE, 0.3)

func pop_prompt() -> void:
	if prompt == null:
		return
	prompt.pivot_offset = prompt.size / 2.0
	prompt.scale = Vector2(0.85, 0.85)
	create_tween().tween_property(prompt, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func choose(i: int) -> void:
	if not running or cooldown:
		return
	if i == ans:
		streak += 1
		add(2 if streak % 5 == 0 else 1)
		flash_opt(i, Color("7dffb0"))
		Sound.tone(900, 0.08, 2)
		next_q()
		pop_prompt()
	else:
		streak = 0
		add(-PENALTY)
		flash_opt(i, Color("ff6b6b"))
		flash_opt(ans, Color("7dffb0"))
		Sound.tone(180, 0.15, 1)
		cooldown = true
		if not await wait(0.3):
			return
		cooldown = false
		if running:
			next_q()
			pop_prompt()

func num_opts(val: int, spread: int = 6) -> void:
	var others = []
	while others.size() < NOPTS - 1:
		var v = val + rng.randi_range(-spread, spread)
		if v != val and v >= 0 and not others.has(v):
			others.append(v)
	var pos = rng.randi() % NOPTS
	for i in NOPTS:
		if i == pos:
			set_opt(i, str(val), col(i))
		else:
			set_opt(i, str(others.pop_back()), col(i))
	ans = pos
