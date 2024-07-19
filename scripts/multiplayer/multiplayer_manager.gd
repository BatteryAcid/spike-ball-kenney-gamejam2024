extends Node

@export var player_spawn_node: Node3D

func _ready():
	# TODO: so this is required to make sure we allow time for the 
	# Main scene to load before adding players from client_connected calls
	await get_tree().process_frame
	
	print("Multiplayer manager getting ready...")
	
	if NetworkManager.is_hosting_game:
		multiplayer.peer_connected.connect(_client_connected)
		multiplayer.peer_disconnected.connect(_del_player)

		print("Adding host player...")
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
	# Vary demo spawn point very slightly
	var spawn_pos =  $"../World/MapSpawnPoint/Marker3D".global_position
	spawn_pos = Vector3(spawn_pos.x * (1 + randf_range(0.01, 0.04)), spawn_pos.y, spawn_pos.z * (1 + randf_range(0.01, 0.04)))
	player_to_add.position = spawn_pos
	player_spawn_node.add_child(player_to_add, true)
	
func _del_player(network_id: int):
	print("Removing player from game...")
