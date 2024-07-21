extends Node

@export var player_spawn_node: Node3D
@export var map_ref: Node3D

var players_in_game: Dictionary = {}
var current_game_id := 0

const PLAYER_COUNT_TO_START = 3

func _ready():
	# TODO: so this is required to make sure we allow time for the 
	# Main scene to load before adding players from client_connected calls
	await get_tree().process_frame
	
	print("Multiplayer manager getting ready...")
	
	if NetworkManager.is_hosting_game:
		multiplayer.peer_connected.connect(_client_connected)
		multiplayer.peer_disconnected.connect(_del_player)

		print("Adding host player...")
		if not OS.has_feature("dedicated_server"):
			# All players are automatically added, there's no waiting for game to start, just auto-joins
			_add_player_to_game(1)

	NetworkManager.hide_loading()
	print("Multiplayer manager ready!")

func _client_connected(network_id: int):
	print("Client connected %s" % network_id)
	_add_player_to_game(network_id)

func _client_disconnected(network_id: int):
	print("Client disconnected %s" % network_id)
	_del_player(network_id)

func _add_player_to_game(network_id: int):
	print("Adding player to game...")
	var player_to_add = NetworkManager.multiplayer_scene.instantiate()
	player_to_add.name = str(network_id)

	var spawn_marker = _get_random_spawn_marker()
	var spawn_pos = _convert_marker_to_spawn_pos(spawn_marker)

	_ready_player(player_to_add, spawn_pos)
	player_spawn_node.add_child(player_to_add, true)
	players_in_game[network_id] = player_to_add

func _get_random_spawn_marker():
	var spawn_positions = _build_spawn_positions()
	return spawn_positions[randi_range(0, spawn_positions.size() - 1)]

func ready_players_for_game_start():
	var x = 0
	for player_key in players_in_game.keys():
		var player_to_ready = players_in_game[player_key]
		var spawn_marker = _get_random_spawn_marker()
		var spawn_pos = _convert_marker_to_spawn_pos(spawn_marker)
		_ready_player(player_to_ready,spawn_pos)

		x += 1
		reset_world()

func _ready_player(player_to_ready, pos):
	player_to_ready.position = pos
	player_to_ready.locked = false
	player_to_ready.energy.reset()
	player_to_ready.dead = false

func reset_world():
	# - water level
	var ground = map_ref.get_node("Env/ground")
	ground.reset()
	# - cores status
	var cores_node = map_ref.get_node("BattleGround/Cores")
	for core in cores_node.get_children():
		core.reset()
	# - door/lever
	var finish_line = map_ref.get_node("BattleGround/FinishLine")
	finish_line.reset()

func end_gameplay():
	print("End gameplay")
	# TODO: timer
	# TODO: RPC for winner
	ready_players_for_game_start()

func _get_spectator_spawn_pos():
	var spawn_pos =  $"../World/MapSpawnPoint/SpectatorSpawnMarker".global_position
	return Vector3(spawn_pos.x + randf_range(0, 1), spawn_pos.y + randf_range(0, 1), spawn_pos.z + randf_range(0, 1))

func _convert_marker_to_spawn_pos(marker):
	var spawn_pos = marker.global_position
	return Vector3(spawn_pos.x + randf_range(0.1, 0.5), spawn_pos.y, spawn_pos.z + randf_range(0.1, 0.5))
	
func _build_spawn_positions():
	var spawn_markers = $"../World/MapSpawnPoint/PlayerSpawnMarkers".get_children()
	spawn_markers.shuffle()
	return spawn_markers

func check_game_over():
	print("Check game over")
	for player_key in players_in_game.keys():
		var player_to_check = players_in_game[player_key]
		if not player_to_check.dead:
			return
	end_gameplay()

func _del_player(network_id: int):
	print("Removing player from game...")
	if players_in_game.has(network_id):
		var player_to_remove = players_in_game[network_id]
		if player_to_remove:
			player_to_remove.queue_free()
			players_in_game.erase(network_id)
