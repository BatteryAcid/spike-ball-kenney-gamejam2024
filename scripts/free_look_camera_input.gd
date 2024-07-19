extends Node3D

@onready var camera_base : Node3D = $CameraMount
@onready var camera_rot : Node3D = $CameraMount/CameraRot
@onready var camera_3D : Camera3D = $CameraMount/CameraRot/SpringArm3D/Camera3D
var relative_cam: = 0.0

const CAMERA_MOUSE_ROTATION_SPEED := 0.001
const CAMERA_X_ROT_MIN := deg_to_rad(-89.9)
const CAMERA_X_ROT_MAX := deg_to_rad(70)
const CAMERA_UP_DOWN_MOVEMENT = -1

var running = 0

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# TODO: this works, but consider a better approach
	if multiplayer.get_unique_id() == str(get_parent().name).to_int():
		camera_3D.current = true
	else:
		camera_3D.current = false

func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(event.relative * CAMERA_MOUSE_ROTATION_SPEED)
		
func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	camera_base.orthonormalize()
	# TODO: refactor for better practice:
	# https://docs.godotengine.org/en/stable/tutorials/3d/using_transforms.html#say-no-to-euler-angles
	camera_rot.rotation.x = clamp(camera_rot.rotation.x + (CAMERA_UP_DOWN_MOVEMENT * move.y), CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)
	relative_cam = camera_rot.rotation.x

func get_camera_rotation_basis() -> Basis:
	return camera_rot.global_transform.basis

func get_camera_base_quaternion() -> Quaternion:
	return camera_base.global_transform.basis.get_rotation_quaternion()
