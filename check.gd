extends Node

func _ready() -> void:
	var bad = 0
	var d = DirAccess.open("res://")
	for f in d.get_files():
		if f.ends_with(".gd") and f != "check.gd":
			var s = load("res://" + f)
			if s == null or not s.can_instantiate():
				print("FAIL: ", f)
				bad += 1
			else:
				print("ok: ", f)
	print("DONE failures=", bad)
	get_tree().quit()
