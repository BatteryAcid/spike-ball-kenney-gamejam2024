class_name AnimationHandler extends Node

var _current_animation_lib = "standard_animation_lib/"
var _animation_player: AnimationPlayer
var _action_animation_cooldown: float = 0.0 # TODO: TEMP hack for testing action animations

func animate_motion(is_on_floor: bool, velocity: Vector3):
	# TODO: temp hack to allow action animations to play instead of immediately overwritten by walk or whatever
	if _action_animation_cooldown > 0.01:
		return 

	var animation_to_play = ""
	if is_on_floor:
		#if Input.get_action_strength("jump") > 0:
			#animation_to_play = "jump"

		if velocity.length() > 6:
			animation_to_play = "run"
		elif velocity.length() > 0.5:
			animation_to_play = "walk"
		else:
			animation_to_play = "idle"
	else:
		animation_to_play = "jump"
	
	_play_animation(animation_to_play)

func animate_action(animation: String, cooldown: float):
	if animation && animation != "":
		print("Animate action: %s" % animation)
		_play_animation(animation)
		_action_animation_cooldown = cooldown

func _play_animation(animation: String):
	_animation_player.play(_current_animation_lib + animation)

# Signal connection: Should only be called from authority.
# Signal for playing approved animations on non-local clients
func apply_action_animation(animation: String, cooldown: float, requester: int):
	if not is_multiplayer_authority():
		return
	apply_action_animation_rpc.rpc(animation, cooldown, requester)

# Need authority so that calls only come from server (authority).
# Need call_local because in host setups, we need to also animate other players
# on the host machine.
@rpc("authority", "call_local")
func apply_action_animation_rpc(animation: String, cooldown: float, requester: int):
	# TODO: Workaround, refactor later. We should prevent the extra RPC call to the client that made the 
	# activity request, as we've already animated them. Unless that flow changes, this should
	# probably be upgraded in favor of avoiding the send.
	if multiplayer.get_unique_id() != requester:
		animate_action(animation, cooldown)

func _process(delta):
	if _action_animation_cooldown > 0:
		_action_animation_cooldown -= delta
		return

func init(animation_player: AnimationPlayer):
	print("Set animation player")
	_animation_player = animation_player
	
	# We want the animation player to animate on all peers except server (unless host)
	if not multiplayer.is_server() || NetworkManager.is_hosting_game:
		_animation_player.active = true
	else:
		_animation_player.active = false

func stop_animations():
	_animation_player.stop()
