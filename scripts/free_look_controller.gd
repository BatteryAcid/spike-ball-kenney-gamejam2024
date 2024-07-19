extends Node

const ROTATION_INTERPOLATE_SPEED = 10
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# TODO: can these be moved to parent common?
# TODO: make these exports
var player_ref: CharacterBody3D
var player_model: Node3D
var player_input: MovementInput
var camera_input: Node

# TODO: can this be moved to parent common?
func init(_player_ref, _player_model, _player_input, _camera_input):
	player_ref = _player_ref
	player_model = _player_model
	player_input = _player_input
	camera_input = _camera_input

func _process_jump():
	if player_input.jump_input > 0 and player_ref.is_on_floor():
		player_ref.velocity.y = JUMP_VELOCITY * player_input.jump_input

func _physics_process_controller(delta):
	
	_process_jump()
	
	var camera_basis : Basis = camera_input.get_camera_rotation_basis()
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x
	
	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	# NOTE: Model direction issues can be resolved by adding a negative to camera_z, depending on setup.
	var player_lookat_target = camera_z
	
	if player_lookat_target.length() > 0.001:
		var q_from = player_ref.orientation.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(player_lookat_target, Vector3.UP).basis.get_rotation_quaternion()
		
		player_ref.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	else:
		# Rotates player even if standing still
		var q_from = player_ref.orientation.basis.get_rotation_quaternion()
		var q_to = camera_input.get_camera_base_quaternion()
		# Interpolate current rotation with desired one.
		player_ref.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	
	var horizontal_velocity = player_ref.velocity
	horizontal_velocity.y = 0
	
	camera_basis = camera_basis.rotated(camera_basis.x, -camera_basis.get_euler().x)
	
	var input_dir = player_input.motion_input
	
	var direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var position_target = direction * SPEED
	
	if player_input.run_input:
		position_target *= 1.5
	horizontal_velocity = horizontal_velocity.lerp(position_target, 10 * delta)
	
	if horizontal_velocity:
		player_ref.velocity.x = horizontal_velocity.x
		player_ref.velocity.z = horizontal_velocity.z
	else:
		player_ref.velocity.x = move_toward(player_ref.velocity.x, 0, SPEED)
		player_ref.velocity.z = move_toward(player_ref.velocity.z, 0, SPEED)

	player_ref.move_and_slide()

	player_ref.orientation.origin = Vector3()
	player_ref.orientation = player_ref.orientation.orthonormalized()
	player_model.global_transform.basis = player_ref.orientation.basis
