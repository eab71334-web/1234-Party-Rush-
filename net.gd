extends Node
signal lobby_changed
signal voting_started
signal vote_update(votes)
signal game_start(game_id, n, seed_val)
signal action_received(seat, data)
signal scores_changed(scores, dones)
signal disconnected
signal player_withdrew(seat)
signal player_left(seat)
signal failed

var active = false
var is_host = false
var my_seat = 0
var count = 2
var seats = {}
var peer = null
var seed_val = 0
var votes = {}
var last_votes = {}
var race_scores = {}
var race_done = {}
var phase = "lobby"

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_in)
	multiplayer.peer_disconnected.connect(_peer_out)
	multiplayer.server_disconnected.connect(_srv_lost)
	multiplayer.connection_failed.connect(_conn_fail)

func reset_state() -> void:
	active = false
	is_host = false
	my_seat = 0
	seats = {}
	votes = {}
	race_scores = {}
	race_done = {}
	phase = "lobby"

func host(n: int) -> void:
	close()
	count = n
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(7777, n - 1)
	if err != OK:
		peer = null
		failed.emit()
		return
	multiplayer.multiplayer_peer = peer
	active = true
	is_host = true
	my_seat = 0
	seats = {1: 0}
	phase = "lobby"
	lobby_changed.emit()

func join(ip: String) -> void:
	close()
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip.strip_edges(), 7777)
	if err != OK:
		peer = null
		failed.emit()
		return
	multiplayer.multiplayer_peer = peer
	active = true
	is_host = false
	phase = "lobby"

func close() -> void:
	if peer != null:
		peer.close()
	multiplayer.multiplayer_peer = null
	peer = null
	reset_state()

func joined_count() -> int:
	return seats.size() if is_host else lobby_filled

var lobby_filled = 1

func _peer_in(id: int) -> void:
	if not is_host:
		return
	var seat = -1
	var used = seats.values()
	for s in range(1, count):
		if not used.has(s):
			seat = s
			break
	if seat < 0:
		return
	seats[id] = seat
	assign.rpc_id(id, seat, count)
	sync_lobby.rpc(seats.size())
	if seats.size() == count:
		await get_tree().create_timer(0.6).timeout
		if is_host and active:
			begin_voting.rpc()

func _peer_out(id: int) -> void:
	if not is_host or not seats.has(id):
		return
	var left_seat = seats[id]
	seats.erase(id)
	if phase == "lobby":
		sync_lobby.rpc(seats.size())
		return
	if seats.size() < 2:
		disconnected.emit()
		return
	var ids = seats.keys()
	ids.sort_custom(func(a, b): return seats[a] < seats[b])
	var newseats = {}
	var k = 0
	for pid in ids:
		newseats[pid] = k
		k += 1
	seats = newseats
	count = seats.size()
	votes = {}
	for pid in ids:
		if pid != 1:
			reseat.rpc_id(pid, seats[pid], count)
	announce_left.rpc(left_seat)
	sync_votes.rpc(votes)

@rpc("authority", "call_remote", "reliable")
func reseat(seat: int, n: int) -> void:
	my_seat = seat
	count = n
	votes = {}

@rpc("authority", "call_local", "reliable")
func announce_left(seat: int) -> void:
	votes = {}
	player_left.emit(seat)

func withdraw() -> void:
	if not active:
		return
	if is_host:
		announce_withdraw.rpc(0)
	else:
		submit_withdraw.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func submit_withdraw() -> void:
	if not is_host:
		return
	var sid = multiplayer.get_remote_sender_id()
	if seats.has(sid):
		announce_withdraw.rpc(seats[sid])

@rpc("authority", "call_local", "reliable")
func announce_withdraw(seat: int) -> void:
	player_withdrew.emit(seat)

func _srv_lost() -> void:
	if active:
		disconnected.emit()

func _conn_fail() -> void:
	close()
	failed.emit()

@rpc("authority", "call_remote", "reliable")
func assign(seat: int, n: int) -> void:
	my_seat = seat
	count = n
	active = true
	lobby_changed.emit()

@rpc("authority", "call_local", "reliable")
func sync_lobby(filled: int) -> void:
	lobby_filled = filled
	lobby_changed.emit()

@rpc("authority", "call_local", "reliable")
func begin_voting() -> void:
	phase = "vote"
	votes = {}
	voting_started.emit()

func cast_vote(game_id: String) -> void:
	if is_host:
		_record_vote(0, game_id)
	else:
		submit_vote.rpc_id(1, game_id)

@rpc("any_peer", "call_remote", "reliable")
func submit_vote(game_id: String) -> void:
	if not is_host:
		return
	var sid = multiplayer.get_remote_sender_id()
	if seats.has(sid):
		_record_vote(seats[sid], game_id)

func _record_vote(seat: int, game_id: String) -> void:
	votes[seat] = game_id
	sync_votes.rpc(votes)
	if votes.size() >= count:
		var picks = votes.values()
		var chosen = picks[randi() % picks.size()]
		start.rpc(chosen, count, randi())

@rpc("authority", "call_local", "reliable")
func sync_votes(v: Dictionary) -> void:
	votes = v
	vote_update.emit(v)

@rpc("authority", "call_local", "reliable")
func start(game_id: String, n: int, sd: int) -> void:
	last_votes = votes.duplicate()
	votes = {}
	race_scores = {}
	race_done = {}
	seed_val = sd
	phase = "play"
	game_start.emit(game_id, n, sd)

func send_action(data: Dictionary) -> void:
	if is_host:
		deliver.rpc(0, data)
	else:
		submit_action.rpc_id(1, data)

@rpc("any_peer", "call_remote", "reliable")
func submit_action(data: Dictionary) -> void:
	if not is_host:
		return
	var sid = multiplayer.get_remote_sender_id()
	if seats.has(sid):
		deliver.rpc(seats[sid], data)

@rpc("authority", "call_local", "reliable")
func deliver(seat: int, data: Dictionary) -> void:
	action_received.emit(seat, data)

func report(score: int, final: bool) -> void:
	if is_host:
		_store(0, score, final)
	else:
		report_score.rpc_id(1, score, final)

@rpc("any_peer", "call_remote", "reliable")
func report_score(score: int, final: bool) -> void:
	if not is_host:
		return
	var sid = multiplayer.get_remote_sender_id()
	if seats.has(sid):
		_store(seats[sid], score, final)

func _store(seat: int, score: int, final: bool) -> void:
	race_scores[seat] = score
	if final:
		race_done[seat] = true
	sync_scores.rpc(race_scores, race_done)

@rpc("authority", "call_local", "reliable")
func sync_scores(sc: Dictionary, dn: Dictionary) -> void:
	race_scores = sc
	race_done = dn
	scores_changed.emit(sc, dn)

func my_ip() -> String:
	for a in IP.get_local_addresses():
		if a.begins_with("192.168.") or a.begins_with("10.") or a.begins_with("172."):
			return a
	return "?"
