class_name Player extends CharacterBody3D

# TODO:
# - upgrade to animations tree for blending/transitions
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var orientation = Transform3D()

@export var player_controller: Node # TODO: make this a type
@export var player_input: MovementInput
@export var camera_input: Node3D
@export var action_input: ActionInput
@export var active_player_model: Node3D
@export var activity_handler: ActivityHandler
@export var animation_handler: AnimationHandler
@export var health: Health
@export var hurtbox: Node

@onready var health_label = $HealthLabel

var _action_taken: String

func _enter_tree():
	player_input.set_multiplayer_authority(str(name).to_int())
	camera_input.set_multiplayer_authority(str(name).to_int())
	action_input.set_multiplayer_authority(str(name).to_int())

func _ready():
	
	# we only want to emit this server side, as that's where the player's actions are processed (authority)
	if is_multiplayer_authority():
		activity_handler.init(animation_handler.apply_action_animation)
	
	action_input.init(activity_handler)
	
	if player_controller:
		player_controller.init(self, active_player_model, player_input, camera_input)
	
	if active_player_model:
		animation_handler.init(active_player_model.get_node("AnimationPlayer") as AnimationPlayer)

@rpc("call_local", "any_peer")
func _request_action(action_taken_id: int):
	if not is_multiplayer_authority():
		return
	print("Request action: %s, from player: %s" % [action_taken_id, multiplayer.get_remote_sender_id()])
	activity_handler.activity_requested(action_taken_id, multiplayer.get_remote_sender_id())

func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func _physics_process(delta):
	_health_label_upkeep()
	
	# We don't need to run animations on server, unless in host
	if not multiplayer.is_server() || NetworkManager.is_hosting_game:
		animation_handler.animate_motion(is_on_floor(), velocity)
		
	# Only run on client authority to process player actions
	if action_input.get_multiplayer_authority() == multiplayer.get_unique_id():
		
		# On our client authority, we get the player action
		var activity: Activity = action_input.process_input()
		if _is_activity_active(activity):
			# Send the player action to the server-auth to be processed (validated/executed)
			_request_action.rpc_id(1, activity.id)
			# Animate the request locally as if it will be valid (could refactor to make on-success)
			animation_handler.animate_action(activity.animation_use, activity.base_cd)
			
	_apply_gravity(delta)

	player_controller._physics_process_controller(delta)

func _is_activity_active(activity):
	return activity != Activities.NO_ACTIVITY

func _health_label_upkeep():
	if health_label && health:
		health_label.text = str(health.get_health())
