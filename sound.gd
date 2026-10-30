extends Node
var music_on = true
var sfx_on = true
var music_running = false
var pool = []
var idx = 0
var cache = {}
var mp: AudioStreamPlayer

func _ready() -> void:
	for i in 8:
		var p = AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	mp = AudioStreamPlayer.new()
	add_child(mp)

func make(f: float, d: float, wave: int) -> AudioStreamWAV:
	var key = "%d_%d_%d" % [int(f), int(d * 1000), wave]
	if cache.has(key):
		return cache[key]
	var rate = 22050
	var n = int(rate * d)
	var data = PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t = float(i) / rate
		var ph = fmod(t * f, 1.0)
		var s = 0.0
		if wave == 0:
			s = sin(TAU * ph)
		elif wave == 1:
			s = 0.45 if ph < 0.5 else -0.45
		elif wave == 2:
			s = 4.0 * absf(ph - 0.5) - 1.0
		else:
			s = randf() * 2.0 - 1.0
		var env = minf(1.0, t / 0.006) * pow(1.0 - float(i) / n, 2.0)
		data.encode_s16(i * 2, int(clampf(s * env * 0.7, -1.0, 1.0) * 32767.0))
	var st = AudioStreamWAV.new()
	st.format = AudioStreamWAV.FORMAT_16_BITS
	st.mix_rate = rate
	st.data = data
	cache[key] = st
	return st

func tone(f: float, d: float = 0.12, wave: int = 0, vol: float = -6.0) -> void:
	if not sfx_on:
		return
	var p = pool[idx]
	idx = (idx + 1) % pool.size()
	p.stream = make(f, d, wave)
	p.volume_db = vol
	p.play()

func click() -> void:
	tone(880, 0.05, 2, -8.0)

func win() -> void:
	for f in [523, 659, 784, 1047]:
		tone(f, 0.18, 2)
		await get_tree().create_timer(0.12).timeout

func lose() -> void:
	for f in [400, 330, 260]:
		tone(f, 0.2, 1, -10.0)
		await get_tree().create_timer(0.14).timeout

func music() -> void:
	if music_running:
		return
	music_running = true
	var notes = [0, 3, 5, 7, 10, 12, 10, 7, 5, 3]
	var i = 0
	while true:
		if music_on:
			var f = 220.0 * pow(2.0, notes[(i * 3) % notes.size()] / 12.0)
			mp.stream = make(f, 0.6, 0)
			mp.volume_db = -22.0
			mp.play()
		i += 1
		await get_tree().create_timer(0.5).timeout
