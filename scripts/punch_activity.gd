class_name PunchActivity extends Node3D

const ACTIVITY_ID: int = 1

var _active = false # We can reuse this attack by flipping this status to true
var _requester: int = -1 # TODO: for now we use network id, later probably player id
var attack_origin_raycast: RayCast3D
var _ttl: float = 0.5 # how long the activity is active
var _collided_yet := false # Prevents duplicate hits

func _physics_process(delta):
	if _active == true:
		if attack_origin_raycast.is_colliding() and not _collided_yet:
			_collided_yet = true
			var body_hit = attack_origin_raycast.get_collider()
			if body_hit is Player:
				print("Player [%s] hit by [%s]'s %s" % [body_hit.name, _requester, name])
				apply_activity(body_hit)

# Here we add the activity to the activity queue of the player it hit, to be processed.
func apply_activity(body_hit):
	body_hit.activity_handler.apply_activity_request(ACTIVITY_ID)

func mark_active():
	_active = true
	await get_tree().create_timer(_ttl).timeout
	_active = false
	_collided_yet = false

func init(player_forward: Node3D):
	if not attack_origin_raycast:
		attack_origin_raycast = player_forward.get_node(Activities.ATTACK_ORIGIN_RAYCAST_NAME)

func _ready():
	# TODO: if we tie in animations with this node, we may have to undo this
	# Don't run on clients
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)

