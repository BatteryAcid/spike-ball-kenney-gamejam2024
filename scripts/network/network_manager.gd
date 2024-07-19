extends Node

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }

@export var _players_spawn_node: Node2D

var _loading_scene = preload("res://scenes/loading.tscn")
var _active_loading_scene
var is_hosting_game = false

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var _enet_network_scene_path = "res://scenes/network/enet_network.tscn"
#var steam_network_scene := preload("res://scenes/network/enet_network.tscn")
var _active_network

var multiplayer_scene = preload("res://scenes/player.tscn")

func host_game(active_network_):
	print("Host game")
	show_loading()
	is_hosting_game = true
	
	# loads and instantiates selected network scene
	_build_multiplayer_network(active_network_)
	# create server peer on choosen network implementation
	_active_network.create_server_peer()

func join_hosted_game(active_network_):
	print("Join hosted game")
	show_loading()
	
	# loads and instantiates selected network scene
	_build_multiplayer_network(active_network_)
	# create client peer on choosen network implementation
	_active_network.create_client_peer()

func _build_multiplayer_network(active_network_):
	if not active_network_:
		print("Setting active_network_")
		
		#MultiplayerManager.multiplayer_mode_enabled = true
		
		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				print("Setting network type to ENet")
				var enet_network_scene = load(_enet_network_scene_path)
				_set_active_network(enet_network_scene)
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				print("*** TODO - Not yet supported - Setting network type to Steam")
				#_set_active_network(steam_network_scene)
			_:
				print("No match for network type!")

func _set_active_network(active_network_scene):
	var network_scene_initialized = active_network_scene.instantiate()
	_active_network = network_scene_initialized

	# Adds under the NetworkManager's top level node
	add_child(_active_network)

func show_loading():
	_active_loading_scene = _loading_scene.instantiate()
	add_child(_active_loading_scene)
	
func hide_loading():
	if _active_loading_scene:
		remove_child(_active_loading_scene)
		_active_loading_scene.queue_free()
