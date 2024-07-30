extends Node3D

var multiplayer_manager: Node

@onready var door_animation_player = $"door-rotate-large2/AnimationPlayer"
@onready var lever_animation_player = $lever2/AnimationPlayer
@onready var lever_label = $lever2/LeverLabel

var _current_animation = ""
var _player_opening_lever: Player
var _lever_charged := false
var _lever_label_text := ""

func _does_player_meet_winning_states(player: Player):
	return player.energy.max_energy_reached()

func _on_area_3d_body_entered(body):
	print("Finish line hit")
	if body is Player:
		print("You win!")
		if is_multiplayer_authority():
			multiplayer_manager.end_gameplay()
			# TODO: kickoff end game stuff and show winner

func _lever_body_entered(body):
	if body is Player and not _player_opening_lever and not _lever_charged:
		print("Lever line hit")
		if _does_player_meet_winning_states(body):
			_player_opening_lever = body
			$FinishLineChargeTimer.start(3)
			_lever_label_text = "Charging"
		else:
			# TODO: add message
			print("Player does not have enough energy...")
			_lever_label_text = "Not enough energy!"

func _on_lever_exited(body):
	print("Player left lever")
	$FinishLineChargeTimer.stop()
	_player_opening_lever = null
	if not _lever_charged:
		_lever_label_text = ""

func _on_finish_line_charge_complete():
	print("On charge complete")
	if _player_opening_lever:
		_lever_charged = true
		lever_animation_player.play("toggle-on")
		door_animation_player.play("open")
		_lever_label_text = "Charge Complete"

func _ready():
	door_animation_player.play("close")
	multiplayer_manager = get_tree().current_scene.get_node("MultiplayerManager")

func _physics_process(delta):
	if lever_label:
		lever_label.text = _lever_label_text

func reset():
	print("Reset finish line!")
	_player_opening_lever = null
	_lever_charged = false
	lever_animation_player.play("toggle-off")
	door_animation_player.play("close")
	_lever_label_text = ""
	_reset_client.rpc()

@rpc("authority")
func _reset_client():
	lever_animation_player.play("toggle-off")
	door_animation_player.play("close")
