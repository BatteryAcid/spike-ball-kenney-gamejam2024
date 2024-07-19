extends Node

const SPEED = 5.0

# TODO: can these be moved to parent common?
var player_ref: CharacterBody3D
var player_model: Node3D
var camera_input: Node

func init(_player_ref, _player_model, _camera_input):
	player_ref = _player_ref
	player_model = _player_model
	camera_input = _camera_input

func _physics_process_controller(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	# Added the negative here to put the camera behind player
	var direction = -(player_ref.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		player_ref.velocity.x = direction.x * SPEED
		player_ref.velocity.z = direction.z * SPEED
	else:
		player_ref.velocity.x = move_toward(player_ref.velocity.x, 0, SPEED)
		player_ref.velocity.z = move_toward(player_ref.velocity.z, 0, SPEED)

	player_ref.move_and_slide()
