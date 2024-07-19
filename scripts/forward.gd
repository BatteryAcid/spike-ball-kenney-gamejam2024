class_name Forward extends Node3D

# A helper class to define player forward, as we don't turn top level player node, but the model.
# Share this instead of the model for forward reference.

@export var player_model_ref: Node3D
@export var attack_origin_ref: RayCast3D
@export var camera_input: Node3D

var cam_rot

func _ready():
	global_transform = player_model_ref.global_transform
	attack_origin_ref.position = Vector3(0, 1, 0.20)
	
	cam_rot = camera_input.get_node("CameraMount/CameraRot")

func _physics_process(delta):
	global_transform = player_model_ref.global_transform

	var cam_rot_basis = cam_rot.transform.basis.inverse()
	attack_origin_ref.transform.basis = cam_rot_basis.orthonormalized()
