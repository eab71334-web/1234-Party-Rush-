extends Control

const FILES = ["art", "base", "bg", "carousel", "g_2048", "g_balloon", "g_boxes", "g_bubble", "g_c4", "g_cardduel", "g_chess", "g_clash", "g_compare", "g_dice", "g_dodge", "g_dotcount", "g_eight", "g_evenodd", "g_flappy", "g_frenzy", "g_goldgrab", "g_gomoku", "g_greenonly", "g_guess", "g_half", "g_highlow", "g_ladders", "g_lane", "g_leftright", "g_lights", "g_math", "g_memgrid", "g_memory", "g_missing", "g_mover", "g_nim", "g_numbermem", "g_odd", "g_opposite", "g_order", "g_pattern", "g_pig", "g_pong", "g_qmath", "g_quickdraw", "g_reaction", "g_reversi", "g_rps", "g_sequence", "g_shapes", "g_simon", "g_slide", "g_snake", "g_stack", "g_stars", "g_stroop", "g_swipe", "g_tapcolor", "g_taprace", "g_thief", "g_timing", "g_tug", "g_whack", "g_xo", "games", "menu", "quiz", "race", "sound"]

func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var bg = ColorRect.new()
	bg.color = Color("1b1030")
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	var txt = "Files check\n"
	var bad = 0
	for f in FILES:
		var s = load("res://%s.gd" % f)
		if s == null or not s.can_instantiate():
			txt += "X " + f + "\n"
			bad += 1
	if bad == 0:
		call_deferred("start")
		return
	var l = Label.new()
	l.set_anchors_preset(PRESET_FULL_RECT)
	l.offset_top = 90
	l.offset_left = 30
	l.add_theme_font_size_override("font_size", 30)
	l.text = txt
	add_child(l)
	var b = Button.new()
	b.text = "Start anyway"
	b.add_theme_font_size_override("font_size", 40)
	b.set_anchors_preset(PRESET_BOTTOM_WIDE)
	b.offset_top = -150
	b.offset_bottom = -40
	b.offset_left = 30
	b.offset_right = -30
	b.pressed.connect(start)
	add_child(b)

func start() -> void:
	var m = Control.new()
	m.set_script(load("res://menu.gd"))
	get_tree().root.add_child(m)
	queue_free()
