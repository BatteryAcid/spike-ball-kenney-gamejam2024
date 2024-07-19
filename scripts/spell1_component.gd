extends RigidBody3D

# IMPORTANT: RigidBody of the component must have Contact Monitor set to on AND Max Contacts Reports set to 1

# TODO: can this script be generic for all components??

var _activity_name: String
var _activity_id: int
var _has_hit := false
var _player_collision_shape

func _ready():
	# We get the collision shape from the ComponentSpawnPoint because this is the only place/time
	# we can set it on the client. Because this is multiplayer, this allows us to avoid seeing
	# a false collision on clients (non-hosts).
	_player_collision_shape = get_parent()._player_collision_shape
	
	if _player_collision_shape:
		# Don't hit self
		add_collision_exception_with(_player_collision_shape)

# TODO: fix activity_name to use friendly name
func init(ttl_: float, activity_name, activity_id):
	_activity_name = activity_name
	_activity_id = activity_id
	
	await get_tree().create_timer(ttl_).timeout
	queue_free()

func _component_collision(body_hit):
	# TODO: this can be expanded to run on all clients to help with animation
	if is_multiplayer_authority():
		if not _has_hit and body_hit is Player:
			print("Player [%s] hit by %s" % [body_hit.name, _activity_name])
			_has_hit = true
			_apply_activity(body_hit)

# Here we add the activity to the activity queue of the player it hit, to be processed.
func _apply_activity(body_hit):
	body_hit.activity_handler.apply_activity_request(_activity_id)


