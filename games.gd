extends Node
signal restart_req
var last = []
var lang = "ar"
var sfx_on = true
var music_on = true
var show_fps = false
var max_fps = 60
var fps_label: Label
var rx = RegEx.new()
var rx_win = RegEx.new()
var rx_turn = RegEx.new()
var PC = [Color("ff5d73"), Color("4da3ff"), Color("3ddc97"), Color("ffc93c")]
const PN_AR = ["الأحمر", "الأزرق", "الأخضر", "الأصفر"]
const PN_EN = ["Red", "Blue", "Green", "Yellow"]
var PN = ["الأحمر", "الأزرق", "الأخضر", "الأصفر"]
var PIECES = {}

# [id, اسم, مسار, أقل, أكثر, لون1, لون2, name, نمط(L=محلي B=الاثنين N=شبكة), أيقونة]
const ALL = [
	["chess", "شطرنج", "res://g_chess.gd", 2, 4, "c9822b", "6b3d12", "Chess", "B", 0],
	["xo", "إكس أو", "res://g_xo.gd", 1, 2, "ff5d73", "a82a45", "Tic Tac Toe", "B", 0],
	["c4", "أربعة في صف", "res://g_c4.gd", 2, 2, "4da3ff", "1f4fb3", "Connect 4", "B", 0],
	["tap", "سباق النقر", "res://g_taprace.gd", 1, 4, "ffb03b", "c26a00", "Tap Race", "L", 0],
	["memory", "الذاكرة", "res://g_memory.gd", 1, 4, "a55eea", "5b2a9c", "Memory", "B", 0],
	["snake", "الثعبان", "res://g_snake.gd", 1, 1, "26de81", "0b8a4d", "Snake", "L", 0],
	["2048", "2048", "res://g_2048.gd", 1, 1, "fd9644", "c0561a", "2048", "L", 0],
	["react", "سرعة البديهة", "res://g_reaction.gd", 1, 4, "eb3b5a", "8c1230", "Reflex", "L", 0],
	["tug", "شد الحبل", "res://g_tug.gd", 2, 2, "2bcbba", "11766b", "Tug of War", "L", 0],
	["rps", "حجر ورقة مقص", "res://g_rps.gd", 2, 2, "fa8231", "b34d0a", "Rock Paper Scissors", "B", 0],
	["guess", "خمّن الرقم", "res://g_guess.gd", 1, 4, "45aaf2", "1b5f99", "Guess the Number", "L", 0],
	["pong", "بينغ بونغ", "res://g_pong.gd", 1, 2, "4b7bec", "1f3fa8", "Pong", "L", 0],
	["whack", "اضرب الخلد", "res://g_whack.gd", 1, 1, "a5774a", "5c3a1c", "Whack-a-Mole", "L", 0],
	["gomoku", "خمسة في صف", "res://g_gomoku.gd", 2, 4, "778ca3", "3d4b5e", "Gomoku", "B", 0],
	["reversi", "ريفيرسي", "res://g_reversi.gd", 2, 2, "20bf6b", "0b6b36", "Reversi", "B", 0],
	["dice", "سباق النرد", "res://g_dice.gd", 2, 4, "f7b731", "b07a00", "Dice Race", "L", 0],
	["math", "تحدي الحساب", "res://g_math.gd", 1, 4, "0fb9b1", "066b66", "Math Duel", "L", 0],
	["simon", "سايمون", "res://g_simon.gd", 1, 1, "8854d0", "461f85", "Simon", "L", 0],
	["slide", "بازل الأرقام", "res://g_slide.gd", 1, 1, "fc5c65", "9a1f2a", "Sliding Puzzle", "L", 0],
	["lights", "أطفئ الأضواء", "res://g_lights.gd", 1, 1, "e1b12c", "8a6a00", "Lights Out", "L", 0],
	["bubble", "فقاعات", "res://g_bubble.gd", 2, 4, "4dc3ff", "1b5f99", "Bubble Pop", "N", 2],
	["stroop", "لون الحبر", "res://g_stroop.gd", 2, 4, "ff6b6b", "8c1f1f", "Ink Match", "N", 20],
	["tapcolor", "اضغط اللون", "res://g_tapcolor.gd", 2, 4, "feca57", "a67c00", "Tap the Color", "N", 7],
	["qmath", "حساب سريع", "res://g_qmath.gd", 2, 4, "2ed573", "0b7a3a", "Quick Math", "N", 24],
	["compare", "الأكبر", "res://g_compare.gd", 2, 4, "00d2d3", "06706f", "Bigger Number", "N", 11],
	["evenodd", "زوجي أو فردي", "res://g_evenodd.gd", 2, 4, "ee5a24", "8a2d0f", "Even or Odd", "N", 17],
	["shapes", "طابق الشكل", "res://g_shapes.gd", 2, 4, "10ac84", "0a5f48", "Shape Match", "N", 3],
	["dotcount", "عدّ النقاط", "res://g_dotcount.gd", 2, 4, "5f27cd", "2a0f6b", "Dot Count", "N", 28],
	["missing", "الرقم الناقص", "res://g_missing.gd", 2, 4, "ff9f43", "a3560c", "Missing Number", "N", 22],
	["sequence", "المتتالية", "res://g_sequence.gd", 2, 4, "48dbfb", "0b6b85", "Next in Line", "N", 21],
	["leftright", "يمين أو يسار", "res://g_leftright.gd", 2, 4, "ff7979", "9b2d2d", "Left or Right", "N", 11],
	["opposite", "العكس", "res://g_opposite.gd", 2, 4, "badc58", "5e7d12", "Opposite", "N", 11],
	["half", "النصف", "res://g_half.gd", 2, 4, "f78fb3", "8a2b52", "Half It", "N", 1],
	["odd", "اكتشف المختلف", "res://g_odd.gd", 2, 4, "a55eea", "4a1f8a", "Odd One Out", "N", 4],
	["order", "رتّب الأرقام", "res://g_order.gd", 2, 4, "ffa502", "a15c00", "Number Order", "N", 19],
	["stars", "اصطد النجوم", "res://g_stars.gd", 2, 4, "fed330", "a88a00", "Star Catcher", "N", 0],
	["dodge", "تفادى", "res://g_dodge.gd", 2, 4, "ff4757", "8a1020", "Dodge", "N", 3],
	["balloon", "المنفاخ", "res://g_balloon.gd", 2, 4, "ff6b9d", "8f2850", "Balloon Pump", "N", 15],
	["mover", "الهدف المتحرك", "res://g_mover.gd", 2, 4, "1dd1a1", "0b6b52", "Moving Target", "N", 10],
	["pattern", "ذاكرة الألوان", "res://g_pattern.gd", 2, 4, "8854d0", "3d1d7a", "Color Memory", "N", 9],
	["swipe", "اتجاه السهم", "res://g_swipe.gd", 2, 4, "48dbfb", "14607a", "Arrow Swipe", "N", 11],
	["lane", "ثلاثة مسارات", "res://g_lane.gd", 2, 4, "54a0ff", "1a4f99", "Lane Runner", "N", 18],
	["stack", "برج الكتل", "res://g_stack.gd", 2, 4, "f368e0", "8a1f7d", "Block Tower", "N", 19],
	["timing", "التوقيت المثالي", "res://g_timing.gd", 2, 4, "feca57", "8d6b00", "Perfect Timing", "N", 22],
	["flappy", "الصاروخ", "res://g_flappy.gd", 2, 4, "2e86de", "0f3d6e", "Rocket Dash", "N", 12],
	["greenonly", "الأخضر فقط", "res://g_greenonly.gd", 2, 4, "26de81", "0b7a3a", "Green Only", "N", 25],
	["quickdraw", "السحب السريع", "res://g_quickdraw.gd", 2, 4, "ff6348", "9a2210", "Quick Draw", "N", 6],
	["numbermem", "ذاكرة الأرقام", "res://g_numbermem.gd", 2, 4, "7d5fff", "33208a", "Number Memory", "N", 20],
	["frenzy", "جنون النقر", "res://g_frenzy.gd", 2, 4, "ffb142", "a15f00", "Tap Frenzy", "N", 29],
	["memgrid", "شبكة الذاكرة", "res://g_memgrid.gd", 2, 4, "c56cf0", "5b1d78", "Grid Memory", "N", 28],
	["clash", "كولور كلاش", "res://g_clash.gd", 2, 4, "ff5252", "b71c1c", "Color Clash", "N", 16],
	["eight", "الثمانيات", "res://g_eight.gd", 2, 4, "ff7043", "bf360c", "Eight Rush", "N", 30],
	["thief", "لصّ الأوراق", "res://g_thief.gd", 2, 4, "26a69a", "00695c", "Pile Thief", "N", 16],
	["ladders", "السلالم", "res://g_ladders.gd", 2, 4, "66bb6a", "2e7d32", "Snakes & Ladders", "N", 26],
	["pig", "نرد الخنزير", "res://g_pig.gd", 2, 4, "ffca28", "c77700", "Pig Dice", "N", 17],
	["boxes", "الصناديق", "res://g_boxes.gd", 2, 4, "42a5f5", "1565c0", "Dots & Boxes", "N", 28],
	["nim", "عيدان", "res://g_nim.gd", 2, 4, "a1887f", "4e342e", "Nim Sticks", "N", 27],
	["highlow", "أعلى أم أقل", "res://g_highlow.gd", 2, 4, "ab47bc", "6a1b9a", "Higher or Lower", "N", 16],
	["goldgrab", "اخطف الذهب", "res://g_goldgrab.gd", 2, 4, "ffd54f", "b28900", "Gold Grab", "N", 13],
	["cardduel", "مبارزة الأوراق", "res://g_cardduel.gd", 2, 4, "26c6da", "006978", "Card Duel", "N", 16],
]

const EXACT = {"تم": "OK", "حذف": "Del", "؟": "?"}
const DICT = [
	["الخصم ما عنده حركة — دورك مرة ثانية", "Opponent can't move - your turn again"],
	["خمّن رقم من 1 إلى 100", "Guess a number from 1 to 100"],
	["انتظر اللون الأخضر...", "Wait for green..."],
	["اضغط بسرعة! الهدف", "Tap fast! Goal"],
	["اسحب لتغيير الاتجاه", "Swipe to steer"],
	["اسحب لدمج الأرقام", "Swipe to merge"],
	["أطفئ كل الأضواء", "Turn off all lights"],
	["شاهد... المستوى", "Watch... Level"],
	["وصلت للمستوى", "You reached level"],
	["أطفأتها في", "Solved in"],
	["حليتها في", "Solved in"],
	["حرّك بإصبعك", "Drag your finger"],
	["استعجل! -1", "too early! -1"],
	["اضغط الآن!!", "TAP NOW!!"],
	["اضغط بسرعة!", "Tap fast!"],
	["خمّن الرقم", "guessed the number"],
	["مرة ثانية", "Play again"],
	["شد الحبل!", "Tug of war!"],
	["خلصت في", "Finished in"],
	["نتيجتك", "Your score"],
	["نقاطك", "Your points"],
	["النتيجة", "Score"],
	["السؤال", "Question"],
	["الحركات", "Moves"],
	["انتهت", "Game over"],
	["تعادل", "Draw"],
	["دورك", "Your turn"],
	["ثانية", "sec"],
	["حركة", "moves"],
	["الرقم", "Number"],
	["أكبر", "higher"],
	["أصغر", "lower"],
	[" من ", " of "],
]

func _ready() -> void:
	rx_win.compile("فاز (\\S+)")
	rx_turn.compile("دور (\\S+)")
	load_cfg()
	var cl = CanvasLayer.new()
	cl.layer = 100
	add_child(cl)
	fps_label = Label.new()
	fps_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	fps_label.offset_left = 16
	fps_label.offset_top = -60
	fps_label.offset_right = 300
	fps_label.offset_bottom = -16
	fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fps_label.add_theme_font_size_override("font_size", 26)
	fps_label.add_theme_color_override("font_color", Color.LIME)
	fps_label.add_theme_color_override("font_outline_color", Color.BLACK)
	fps_label.add_theme_constant_override("outline_size", 6)
	cl.add_child(fps_label)
	apply()
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

func _process(_d: float) -> void:
	if show_fps:
		fps_label.text = "FPS %d" % Engine.get_frames_per_second()

func load_cfg() -> void:
	var c = ConfigFile.new()
	if c.load("user://settings.cfg") == OK:
		lang = c.get_value("s", "lang", "ar")
		sfx_on = c.get_value("s", "sfx", true)
		music_on = c.get_value("s", "music", true)
		show_fps = c.get_value("s", "showfps", false)
		max_fps = c.get_value("s", "maxfps", 60)

func save_cfg() -> void:
	var c = ConfigFile.new()
	c.set_value("s", "lang", lang)
	c.set_value("s", "sfx", sfx_on)
	c.set_value("s", "music", music_on)
	c.set_value("s", "showfps", show_fps)
	c.set_value("s", "maxfps", max_fps)
	c.save("user://settings.cfg")

func apply() -> void:
	Engine.max_fps = max_fps
	Sound.sfx_on = sfx_on
	Sound.music_on = music_on
	PN = PN_EN.duplicate() if lang == "en" else PN_AR.duplicate()
	if fps_label:
		fps_label.visible = show_fps

func L(ar: String, en: String) -> String:
	return en if lang == "en" else ar

func strip(s: String) -> String:
	var out = ""
	for i in s.length():
		var c = s.unicode_at(i)
		if c >= 0x1F000 or (c >= 0x2190 and c <= 0x21FF) or (c >= 0x2300 and c <= 0x2BFF) or c == 0xFE0F or c == 0x200D:
			continue
		out += s.substr(i, 1)
	return out.strip_edges()

func tx(s: String) -> String:
	s = strip(s)
	if lang != "en":
		return s
	if EXACT.has(s):
		return EXACT[s]
	s = rx_win.sub(s, "$1 wins", true)
	s = rx_turn.sub(s, "$1's turn", true)
	for p in DICT:
		s = s.replace(p[0], p[1])
	return s

func games_for(n: int, lan: bool = false) -> Array:
	return ALL.filter(func(g): return n >= g[3] and n <= g[4] and (g[8] != "N" if not lan else g[8] != "L"))

func find_game(id: String) -> Array:
	for g in ALL:
		if g[0] == id:
			return g
	return ALL[0]

func set_landscape(on: bool) -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE if on else DisplayServer.SCREEN_PORTRAIT)

func safe_top() -> int:
	var ws = DisplayServer.window_get_size()
	var sa = DisplayServer.get_display_safe_area()
	if ws.x <= 0:
		return 40
	var k = 720.0 / float(ws.x)
	return int(maxf(sa.position.y * k, 40.0))

func flat(c: Color, r: int = 12) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(r)
	return s

func style(c: Color, r: int = 28, depth: int = 10) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(r)
	s.border_width_bottom = depth
	s.border_color = c.darkened(0.38)
	s.shadow_color = Color(0, 0, 0, 0.3)
	s.shadow_size = 10
	s.shadow_offset = Vector2(0, 8)
	s.content_margin_left = 16
	s.content_margin_right = 16
	return s

func tint(b: Button, c: Color) -> void:
	b.add_theme_stylebox_override("normal", style(c))
	b.add_theme_stylebox_override("hover", style(c.lightened(0.1)))
	b.add_theme_stylebox_override("pressed", style(c.darkened(0.12), 28, 3))

func btn(text: String, color: Color = Color("6c5ce7"), h: int = 110, fs: int = 40) -> Button:
	var b = Button.new()
	b.text = tx(text)
	b.custom_minimum_size = Vector2(0, h)
	b.add_theme_font_size_override("font_size", fs)
	tint(b, color)
	b.add_theme_stylebox_override("disabled", style(color.darkened(0.45)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.35))
	b.add_theme_constant_override("outline_size", 6)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.6))
	b.button_down.connect(func():
		b.pivot_offset = b.size / 2
		get_tree().create_tween().tween_property(b, "scale", Vector2(0.94, 0.94), 0.06))
	b.button_up.connect(func():
		b.pivot_offset = b.size / 2
		get_tree().create_tween().tween_property(b, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
	b.pressed.connect(Sound.click)
	return b

func icon_btn(kind: String, color: Color, sz: int = 100) -> Button:
	var b = btn("", color, sz, 20)
	b.custom_minimum_size = Vector2(sz, sz)
	var a = Control.new()
	a.set_script(load("res://art.gd"))
	a.set("kind", kind)
	a.set_anchors_preset(Control.PRESET_FULL_RECT)
	b.add_child(a)
	return b

func pop(n: Control, d: float = 0.0) -> void:
	n.modulate.a = 0.0
	n.scale = Vector2(0.6, 0.6)
	n.pivot_offset = n.custom_minimum_size / 2
	n.resized.connect(func(): n.pivot_offset = n.size / 2)
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property(n, "modulate:a", 1.0, 0.3).set_delay(d)
	t.tween_property(n, "scale", Vector2.ONE, 0.5).set_delay(d).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func back(node: Control) -> void:
	var b = icon_btn("close", Color("e17055"), 90)
	b.position = Vector2(20, safe_top())
	b.size = Vector2(90, 90)
	b.pressed.connect(func():
		if Net.active:
			Net.withdraw()
			restart_req.emit()
		else:
			get_tree().reload_current_scene())
	node.add_child(b)

func ell(cx: float, cy: float, rx2: float, ry2: float, n: int = 18) -> PackedVector2Array:
	var a = PackedVector2Array()
	for i in n:
		var ang = TAU * i / n
		a.append(Vector2(cx + cos(ang) * rx2, cy + sin(ang) * ry2))
	return a

func pv(arr: Array) -> PackedVector2Array:
	var a = PackedVector2Array()
	for i in range(0, arr.size(), 2):
		a.append(Vector2(arr[i], arr[i + 1]))
	return a

func build_pieces() -> void:
	var plinth = pv([-0.30, 0.40, -0.30, 0.31, 0.30, 0.31, 0.30, 0.40])
	var qbody = pv([-0.20, 0.31, -0.11, -0.10, 0.11, -0.10, 0.20, 0.31])
	PIECES["P"] = [[pv([-0.09, -0.09, 0.09, -0.09, 0.17, 0.31, -0.17, 0.31]), 0], [ell(0, -0.2, 0.13, 0.13), 0], [plinth, 0]]
	PIECES["R"] = [[pv([-0.20, 0.31, -0.16, -0.15, 0.16, -0.15, 0.20, 0.31]), 0],
		[pv([-0.23, -0.15, -0.23, -0.38, -0.12, -0.38, -0.12, -0.30, -0.04, -0.30, -0.04, -0.38, 0.04, -0.38, 0.04, -0.30, 0.12, -0.30, 0.12, -0.38, 0.23, -0.38, 0.23, -0.15]), 0], [plinth, 0]]
	PIECES["B"] = [[pv([-0.16, 0.31, -0.08, 0.0, 0.08, 0.0, 0.16, 0.31]), 0], [ell(0, -0.17, 0.14, 0.21), 0], [ell(0, -0.42, 0.05, 0.05, 10), 0],
		[pv([-0.03, -0.25, 0.09, -0.34, 0.11, -0.31, -0.01, -0.22]), 1], [plinth, 0]]
	PIECES["N"] = [[pv([-0.22, 0.31, -0.20, 0.02, -0.31, 0.0, -0.35, -0.10, -0.15, -0.33, -0.11, -0.43, -0.03, -0.35, 0.10, -0.31, 0.24, -0.12, 0.24, 0.31]), 0],
		[ell(-0.08, -0.2, 0.03, 0.03, 8), 1], [plinth, 0]]
	PIECES["Q"] = [[qbody, 0],
		[pv([-0.21, -0.10, -0.25, -0.34, -0.12, -0.20, -0.06, -0.40, 0.0, -0.22, 0.06, -0.40, 0.12, -0.20, 0.25, -0.34, 0.21, -0.10]), 0],
		[ell(-0.25, -0.36, 0.04, 0.04, 8), 0], [ell(-0.06, -0.43, 0.04, 0.04, 8), 0], [ell(0.06, -0.43, 0.04, 0.04, 8), 0], [ell(0.25, -0.36, 0.04, 0.04, 8), 0], [plinth, 0]]
	PIECES["K"] = [[qbody, 0], [pv([-0.19, -0.10, -0.21, -0.27, 0.21, -0.27, 0.19, -0.10]), 0],
		[pv([-0.03, -0.49, 0.03, -0.49, 0.03, -0.43, 0.09, -0.43, 0.09, -0.37, 0.03, -0.37, 0.03, -0.27, -0.03, -0.27, -0.03, -0.37, -0.09, -0.37, -0.09, -0.43, -0.03, -0.43]), 0], [plinth, 0]]

func piece(ci: CanvasItem, t: String, ctr: Vector2, s: float, fill: Color) -> void:
	if PIECES.is_empty():
		build_pieces()
	ci.draw_set_transform(ctr + Vector2(0, s * 0.36), 0.0, Vector2(1.0, 0.35))
	ci.draw_circle(Vector2.ZERO, s * 0.3, Color(0, 0, 0, 0.28))
	ci.draw_set_transform(ctr, 0.0, Vector2(s, s))
	var ol = Color(0, 0, 0, 0.8)
	for part in PIECES[t]:
		var poly = part[0]
		if part[1] == 1:
			ci.draw_colored_polygon(poly, ol)
		else:
			ci.draw_colored_polygon(poly, fill)
			var pts = poly.duplicate()
			pts.append(poly[0])
			ci.draw_polyline(pts, ol, 0.035)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func glyph(ci: CanvasItem, i: int, c: Vector2, r: float, k: Color) -> void:
	match i:
		0:
			var pts = PackedVector2Array()
			for j in 10:
				var a = -PI / 2.0 + j * PI / 5.0
				pts.append(c + Vector2(cos(a), sin(a)) * (r if j % 2 == 0 else r * 0.45))
			ci.draw_colored_polygon(pts, k)
		1:
			ci.draw_circle(c + Vector2(-0.5, -0.3) * r, r * 0.58, k)
			ci.draw_circle(c + Vector2(0.5, -0.3) * r, r * 0.58, k)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-1.04, -0.05) * r, c + Vector2(1.04, -0.05) * r, c + Vector2(0, 1.0) * r]), k)
		2:
			ci.draw_circle(c, r, k)
			ci.draw_circle(c + Vector2(-0.3, -0.3) * r, r * 0.25, Color(1, 1, 1, 0.5))
		3:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -1) * r, c + Vector2(1, 0.8) * r, c + Vector2(-1, 0.8) * r]), k)
		4:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -1) * r, c + Vector2(0.8, 0) * r, c + Vector2(0, 1) * r, c + Vector2(-0.8, 0) * r]), k)
		5:
			var pts = PackedVector2Array()
			for s in 13:
				var a = deg_to_rad(-47.5 - 265.0 * s / 12.0)
				pts.append(c + Vector2(cos(a), sin(a)) * r)
			for s in 13:
				var a = deg_to_rad(70.8 + 218.4 * s / 12.0)
				pts.append(c + Vector2(0.42 * r, 0) + Vector2(cos(a), sin(a)) * r * 0.78)
			ci.draw_colored_polygon(pts, k)
		6:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0.15, -1) * r, c + Vector2(-0.6, 0.15) * r, c + Vector2(-0.05, 0.15) * r, c + Vector2(-0.2, 1) * r, c + Vector2(0.6, -0.2) * r, c + Vector2(0.05, -0.2) * r]), k)
		7:
			for j in 5:
				var a = j * TAU / 5.0
				ci.draw_circle(c + Vector2(cos(a), sin(a)) * r * 0.55, r * 0.42, k)
			ci.draw_circle(c, r * 0.3, Color("ffe066"))
		8:
			ci.draw_circle(c + Vector2(0, 0.25) * r, r * 0.7, k)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -1) * r, c + Vector2(0.62, 0.05) * r, c + Vector2(-0.62, 0.05) * r]), k)
		9:
			for v in [Vector2(-0.4, -0.3), Vector2(0.4, -0.3), Vector2(-0.4, 0.4), Vector2(0.4, 0.4)]:
				ci.draw_circle(c + v * r, r * 0.45, k)
			ci.draw_line(c, c + Vector2(0.3, 1.1) * r, k.darkened(0.3), r * 0.15)
		10:
			ci.draw_circle(c, r, k)
			ci.draw_circle(c, r * 0.72, Color.WHITE)
			ci.draw_circle(c, r * 0.46, k)
			ci.draw_circle(c, r * 0.2, Color.WHITE)
		11:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -1) * r, c + Vector2(0.8, 0) * r, c + Vector2(0.35, 0) * r, c + Vector2(0.35, 1) * r, c + Vector2(-0.35, 1) * r, c + Vector2(-0.35, 0) * r, c + Vector2(-0.8, 0) * r]), k)
		12:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.35, 0.3) * r, c + Vector2(-0.8, 0.8) * r, c + Vector2(-0.35, 0.6) * r]), k.darkened(0.2))
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0.35, 0.3) * r, c + Vector2(0.8, 0.8) * r, c + Vector2(0.35, 0.6) * r]), k.darkened(0.2))
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -1) * r, c + Vector2(0.38, -0.3) * r, c + Vector2(0.38, 0.7) * r, c + Vector2(-0.38, 0.7) * r, c + Vector2(-0.38, -0.3) * r]), k)
			ci.draw_circle(c + Vector2(0, -0.2) * r, r * 0.17, Color("dff9fb"))
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.25, 0.75) * r, c + Vector2(0.25, 0.75) * r, c + Vector2(0, 1.25) * r]), Color("ffa502"))
		13:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-1, 0.6) * r, c + Vector2(-1, -0.5) * r, c + Vector2(-0.5, 0) * r, c + Vector2(0, -0.8) * r, c + Vector2(0.5, 0) * r, c + Vector2(1, -0.5) * r, c + Vector2(1, 0.6) * r]), k)
			for v in [Vector2(-1, -0.55), Vector2(0, -0.85), Vector2(1, -0.55)]:
				ci.draw_circle(c + v * r, r * 0.12, Color("ff6b81"))
		14:
			ci.draw_circle(c + Vector2(0, 0.15) * r, r * 0.8, Color("2f3542"))
			ci.draw_line(c + Vector2(0.3, -0.55) * r, c + Vector2(0.65, -0.95) * r, Color("b2bec3"), r * 0.1)
			ci.draw_circle(c + Vector2(0.7, -1.0) * r, r * 0.14, Color("ffa502"))
			ci.draw_circle(c + Vector2(-0.3, -0.05) * r, r * 0.15, Color(1, 1, 1, 0.4))
		15:
			var pts = PackedVector2Array()
			for j in 20:
				var a = TAU * j / 20.0
				pts.append(c + Vector2(cos(a) * 0.7, sin(a) * 0.85 - 0.2) * r)
			ci.draw_colored_polygon(pts, k)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, 0.62) * r, c + Vector2(-0.15, 0.85) * r, c + Vector2(0.15, 0.85) * r]), k)
			ci.draw_line(c + Vector2(0, 0.85) * r, c + Vector2(0.1, 1.2) * r, Color(1, 1, 1, 0.7), r * 0.04)
			ci.draw_circle(c + Vector2(-0.25, -0.5) * r, r * 0.14, Color(1, 1, 1, 0.45))
		16:
			for j in 2:
				ci.draw_set_transform(c + Vector2((j - 0.5) * 0.5 * r, 0), (j - 0.5) * 0.45, Vector2.ONE)
				ci.draw_style_box(flat(Color("f5f6fa") if j == 1 else k.lightened(0.2), int(r * 0.15)), Rect2(Vector2(-0.5, -0.75) * r, Vector2(1.0, 1.5) * r))
				if j == 1:
					ci.draw_circle(Vector2(-0.12, -0.1) * r, r * 0.17, Color("e74c3c"))
					ci.draw_circle(Vector2(0.12, -0.1) * r, r * 0.17, Color("e74c3c"))
					ci.draw_colored_polygon(PackedVector2Array([Vector2(-0.28, -0.02) * r, Vector2(0.28, -0.02) * r, Vector2(0, 0.38) * r]), Color("e74c3c"))
			ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		17:
			ci.draw_style_box(flat(Color("f5f6fa"), int(r * 0.3)), Rect2(c - Vector2(r, r) * 0.9, Vector2(r, r) * 1.8))
			for v in [Vector2(-1, -1), Vector2(1, -1), Vector2(0, 0), Vector2(-1, 1), Vector2(1, 1)]:
				ci.draw_circle(c + v * r * 0.45, r * 0.16, Color("2d3436"))
		18:
			ci.draw_line(c + Vector2(-0.6, 1) * r, c + Vector2(-0.6, -1) * r, Color("dfe4ea"), r * 0.12)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.55, -1) * r, c + Vector2(0.9, -0.5) * r, c + Vector2(-0.55, 0.05) * r]), k)
		19:
			ci.draw_style_box(flat(k.darkened(0.2), int(r * 0.1)), Rect2(c + Vector2(-0.9, 0.35) * r, Vector2(1.8, 0.6) * r))
			ci.draw_style_box(flat(k, int(r * 0.1)), Rect2(c + Vector2(-0.7, -0.25) * r, Vector2(1.4, 0.6) * r))
			ci.draw_style_box(flat(k.lightened(0.25), int(r * 0.1)), Rect2(c + Vector2(-0.45, -0.85) * r, Vector2(0.9, 0.6) * r))
		20:
			var pts = PackedVector2Array()
			for j in 20:
				var a = TAU * j / 20.0
				pts.append(c + Vector2(cos(a) * 1.0, sin(a) * 0.6) * r)
			ci.draw_colored_polygon(pts, Color("f5f6fa"))
			ci.draw_circle(c, r * 0.4, k)
			ci.draw_circle(c, r * 0.18, Color.BLACK)
		21:
			var pts = PackedVector2Array()
			for j in 21:
				var x = -1.0 + j * 0.1
				pts.append(c + Vector2(x, sin(x * 4.0) * 0.4) * r)
			ci.draw_polyline(pts, k, r * 0.18)
		22:
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-0.7, -1) * r, c + Vector2(0.7, -1) * r, c + Vector2(0, 0) * r]), k)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, 0) * r, c + Vector2(0.7, 1) * r, c + Vector2(-0.7, 1) * r]), k.darkened(0.25))
		23:
			for j in 8:
				var a = j * TAU / 8.0
				ci.draw_line(c + Vector2(cos(a), sin(a)) * r * 0.7, c + Vector2(cos(a), sin(a)) * r * 1.05, k, r * 0.12)
			ci.draw_circle(c, r * 0.55, k)
		24:
			ci.draw_style_box(flat(k, int(r * 0.1)), Rect2(c + Vector2(-0.25, -0.9) * r, Vector2(0.5, 1.8) * r))
			ci.draw_style_box(flat(k, int(r * 0.1)), Rect2(c + Vector2(-0.9, -0.25) * r, Vector2(1.8, 0.5) * r))
		25:
			ci.draw_polyline(PackedVector2Array([c + Vector2(-0.8, 0.05) * r, c + Vector2(-0.25, 0.65) * r, c + Vector2(0.85, -0.7) * r]), k, r * 0.28)
		26:
			ci.draw_line(c + Vector2(-0.5, -1) * r, c + Vector2(-0.5, 1) * r, k, r * 0.14)
			ci.draw_line(c + Vector2(0.5, -1) * r, c + Vector2(0.5, 1) * r, k, r * 0.14)
			for j in 5:
				ci.draw_line(c + Vector2(-0.5, -0.8 + j * 0.4) * r, c + Vector2(0.5, -0.8 + j * 0.4) * r, k.lightened(0.2), r * 0.1)
		27:
			for j in 4:
				ci.draw_style_box(flat(k.lightened(0.15 * (j % 2)), int(r * 0.1)), Rect2(c + Vector2(-0.9 + j * 0.5, -0.9) * r, Vector2(0.28, 1.8) * r))
		28:
			for x in 3:
				for y in 3:
					ci.draw_circle(c + Vector2(x - 1, y - 1) * r * 0.65, r * 0.17, k)
		29:
			ci.draw_circle(c + Vector2(0, 0.55) * r, r * 0.7, k)
			ci.draw_style_box(flat(k, int(r * 0.2)), Rect2(c + Vector2(-0.2, -1) * r, Vector2(0.4, 1.3) * r))
			ci.draw_arc(c + Vector2(0, -0.9) * r, r * 0.45, 0, TAU, 20, Color(1, 1, 1, 0.7), r * 0.07)
		30:
			ci.draw_circle(c + Vector2(-0.5, 0.15) * r, r * 0.58, k)
			ci.draw_circle(c + Vector2(0.5, 0.15) * r, r * 0.58, k)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-1.04, -0.05) * r, c + Vector2(1.04, -0.05) * r, c + Vector2(0, -1.05) * r]), k)
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, 0.2) * r, c + Vector2(0.35, 1.0) * r, c + Vector2(-0.35, 1.0) * r]), k)

func suit_color(s: int) -> Color:
	return Color("e74c3c") if s < 2 else Color("2d3436")

func pcard(ci: CanvasItem, r: Rect2, rank: int, suit: int, up: bool = true, dim: bool = false) -> void:
	var w = r.size.x
	ci.draw_style_box(style(Color("f5f6fa") if up else Color("3b4cca"), int(w * 0.12), 4), r)
	if not up:
		ci.draw_style_box(flat(Color("5d6fe0"), int(w * 0.08)), Rect2(r.position + Vector2(w * 0.1, w * 0.1), r.size - Vector2(w * 0.2, w * 0.2 + 4)))
		return
	var gl = [1, 4, 9, 30]
	var labels = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
	var k = suit_color(suit)
	glyph(ci, gl[suit], r.position + Vector2(w * 0.5, r.size.y * 0.56), w * 0.26, k)
	ci.draw_string(ThemeDB.fallback_font, r.position + Vector2(w * 0.08, w * 0.34), labels[rank - 1], HORIZONTAL_ALIGNMENT_LEFT, w * 0.5, int(w * 0.32), k)
	if dim:
		ci.draw_style_box(flat(Color(0, 0, 0, 0.45), int(w * 0.12)), r)

func ccolor(i: int) -> Color:
	return [Color("e74c3c"), Color("3d8bfd"), Color("2ecc71"), Color("f1c40f"), Color("2d3436")][i]

func ccard(ci: CanvasItem, r: Rect2, color: int, kind: String, up: bool = true, dim: bool = false) -> void:
	var w = r.size.x
	var h = r.size.y
	var base = ccolor(color) if up else Color("2d3436")
	ci.draw_style_box(style(base, int(w * 0.14), 4), r)
	var ctr = r.position + r.size / 2.0
	ci.draw_set_transform(ctr, -0.45, Vector2(0.62, 1.0))
	ci.draw_circle(Vector2.ZERO, h * 0.4, Color("f5f6fa") if up else Color("e74c3c"))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not up:
		ci.draw_string(ThemeDB.fallback_font, Vector2(r.position.x, ctr.y + h * 0.08), "CC", HORIZONTAL_ALIGNMENT_CENTER, w, int(w * 0.34), Color.WHITE)
		return
	var f = ThemeDB.fallback_font
	var ink = ccolor(color) if color < 4 else Color("2d3436")
	var fs = int(w * 0.5)
	match kind:
		"skip":
			ci.draw_arc(ctr, w * 0.24, 0, TAU, 24, ink, w * 0.07)
			ci.draw_line(ctr + Vector2(-0.17, 0.17) * w, ctr + Vector2(0.17, -0.17) * w, ink, w * 0.07)
		"rev":
			for s in [-1, 1]:
				ci.draw_line(ctr + Vector2(-0.2 * s, -0.1 * s) * w, ctr + Vector2(0.2 * s, -0.1 * s) * w, ink, w * 0.06)
				ci.draw_colored_polygon(PackedVector2Array([ctr + Vector2(0.28 * s, -0.1 * s) * w, ctr + Vector2(0.14 * s, -0.2 * s) * w, ctr + Vector2(0.14 * s, 0.0) * w]), ink)
		"d2":
			ci.draw_string(f, Vector2(r.position.x, ctr.y + fs * 0.35), "+2", HORIZONTAL_ALIGNMENT_CENTER, w, fs, ink)
		"d4":
			ci.draw_string(f, Vector2(r.position.x, ctr.y + fs * 0.35), "+4", HORIZONTAL_ALIGNMENT_CENTER, w, fs, ink)
		"wild":
			for j in 4:
				var a0 = j * PI / 2.0
				var pts = PackedVector2Array([ctr])
				for s in 7:
					var a = a0 + (PI / 2.0) * s / 6.0
					pts.append(ctr + Vector2(cos(a), sin(a)) * w * 0.24)
				ci.draw_colored_polygon(pts, ccolor(j))
		_:
			ci.draw_string(f, Vector2(r.position.x, ctr.y + fs * 0.35), kind, HORIZONTAL_ALIGNMENT_CENTER, w, fs, ink)
	ci.draw_string(f, r.position + Vector2(w * 0.1, w * 0.3), kind if kind.length() <= 1 else ("+2" if kind == "d2" else ("+4" if kind == "d4" else "")), HORIZONTAL_ALIGNMENT_LEFT, w * 0.5, int(w * 0.24), Color.WHITE)
	if dim:
		ci.draw_style_box(flat(Color(0, 0, 0, 0.5), int(w * 0.14)), r)
