extends Control
var c1 = Color("2d1b69")
var c2 = Color("0f0a2a")
var shape = 0
var dots = []
var t = 0.0

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 24:
		dots.append([randf(), randf(), randf_range(16.0, 70.0), randf_range(0.015, 0.055), randf(), randf_range(-1.0, 1.0)])

func _process(d: float) -> void:
	t += d
	for p in dots:
		p[1] -= p[3] * d
		if p[1] < -0.15:
			p[1] = 1.15
			p[0] = randf()
	queue_redraw()

func _draw() -> void:
	var sz = get_viewport_rect().size
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(sz.x, 0), sz, Vector2(0, sz.y)]), PackedColorArray([c1, c1, c2, c2]))
	var lc = c1.lightened(0.55)
	lc.a = 0.13
	for p in dots:
		var pos = Vector2(p[0] * sz.x + sin(t * 0.8 + p[4] * 6.0) * 24.0, p[1] * sz.y)
		if shape == 0:
			draw_circle(pos, p[2], lc)
		else:
			draw_set_transform(pos, t * 0.3 * p[5] + p[4] * 3.0, Vector2.ONE)
			draw_rect(Rect2(-p[2] * 0.8, -p[2] * 0.8, p[2] * 1.6, p[2] * 1.6), lc)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
