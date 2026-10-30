extends "res://g_clash.gd"
const SUITS = [1, 4, 9, 30]

func make_deck() -> Array:
	var d = []
	for s in 4:
		for r in range(1, 14):
			d.append([s, r])
	return d

func is_plain(c) -> bool:
	return c[1] != 8 and c[1] != 1 and c[1] != 2

func is_wild(c) -> bool:
	return c[1] == 8

func playable(c) -> bool:
	return c[1] == 8 or c[0] == cur or c[1] == discard.back()[1]

func cur_color() -> Color:
	return Games.suit_color(cur).lightened(0.4) if cur >= 2 else Games.suit_color(cur)

func draw_c(r: Rect2, c, up: bool, dim: bool) -> void:
	if c == null:
		Games.pcard(body, r, 1, 0, false, false)
	else:
		Games.pcard(body, r, c[1], c[0], up, dim)

func choice_draw(i: int, ctr: Vector2, rad: float) -> void:
	body.draw_circle(ctr, rad, Color("f5f6fa"))
	Games.glyph(body, SUITS[i], ctr, rad * 0.55, Games.suit_color(i))

func after_play(c, seat: int, choice: int) -> int:
	cur = c[0] if c[1] != 8 else clampi(choice, 0, 3)
	if c[1] == 1:
		return 2
	if c[1] == 2:
		give(posmod(seat + dir, players), 2)
		return 2
	return 1
