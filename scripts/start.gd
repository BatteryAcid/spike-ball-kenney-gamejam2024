extends Control

const MAIN_SCENE = "res://scenes/main.tscn"

func enter_world():
	print("Enter world")
	NetworkManager.join_hosted_game(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
	get_tree().call_deferred(&"change_scene_to_packed", preload(MAIN_SCENE))

func host_game():
	print("Host local game")
	NetworkManager.host_game(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
	get_tree().call_deferred(&"change_scene_to_packed", preload(MAIN_SCENE))

func join_game():
	print("Join hosted game")
	NetworkManager.join_hosted_game(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
	get_tree().call_deferred(&"change_scene_to_packed", preload(MAIN_SCENE))

func quit_game():
	get_tree().quit(0)

func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server")
		NetworkManager.host_game(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
		get_tree().call_deferred(&"change_scene_to_packed", preload(MAIN_SCENE))
