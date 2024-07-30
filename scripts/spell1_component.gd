extends RigidBody3D

# IMPORTANT: RigidBody of the component must have Contact Monitor set to on AND Max Contacts Reports set to 1

# TODO: can this script be generic for all components??

const FORCE_TIME_DELAY := 1.0
const SPELL_FORCE := 30#50

var _target_hit = false
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
	
	$Area3D/CollisionShape3D.disabled = true
	$Area3DCollisionTimer.start()

func enable_area3d_collision():
	$Area3D/CollisionShape3D.disabled = false

# TODO: fix activity_name to use friendly name
func init(ttl_: float, activity_name, activity_id):
	_activity_name = activity_name
	_activity_id = activity_id
	
	await get_tree().create_timer(ttl_).timeout
	queue_free()

# TODO: this won't be hit anymore as the Rigidbody is smaller than the Area3D, remove
func _component_collision(body_hit):
	# TODO: this can be expanded to run on all clients to help with animation
	if is_multiplayer_authority():
		if not _has_hit and body_hit is Player:
			print("Player [%s] hit by %s" % [body_hit.name, _activity_name])
			_has_hit = true
			
			# TODO instead of immediately appling activiyt request, create timer then blow up
			#_apply_activity(body_hit)

# TODO:
# Move _has_hit logic here, so we don't continously re-apply velocity
# At that point I think were good, no need to adjust anything else.
func near_player(body_hit):
	if body_hit is Player:
		print("Spell1 near player")
		
		# TODO: fix this velocity to be deterministic
		await get_tree().create_timer(FORCE_TIME_DELAY).timeout
		var force_vel = (body_hit.transform.origin - transform.origin).normalized()
		#print(force_vel)
		var clamped_vel = Vector3(clamp(force_vel.x * SPELL_FORCE, -10, 10), clamp(force_vel.y * SPELL_FORCE, -10, 10), clamp(force_vel.z * SPELL_FORCE, -10, 10))
		#print(clamped_vel)
		body_hit.velocity = clamped_vel# * SPELL_FORCE
		#print(body_hit.velocity)
		
		if is_multiplayer_authority():
			var source_player_id = _player_collision_shape.name
			if body_hit.name != str(source_player_id) and not _target_hit:
				_target_hit = true
				var energy_drained = body_hit.energy.drain_energy(1)
				_player_collision_shape.energy.add_energy(energy_drained)

# TODO: not really using this activity mechanism for this setup.
# Here we add the activity to the activity queue of the player it hit, to be processed.
func _apply_activity(body_hit):
	body_hit.activity_handler.apply_activity_request(_activity_id)


