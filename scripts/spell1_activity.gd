extends Node3D

# NOTE: Since these are spawn from within the player object (may change later), the component must
# be marked "Top Level" in the editor (under Transform). Otherwise the force calculations break.

const ACTIVITY_ID: int = 2

@export var component_spawn_point: Node3D
@export var ttl: float = 3.0 
@export var component_force: float = 500

var _requester: int = -1 # TODO: for now we use network id, later probably player id
var _attack_origin_raycast: RayCast3D
var _component_scene = preload("res://scenes/player/activity/components/spell1_component.tscn")
var _component: RigidBody3D

# TODO: probably pull these from a queue

func launch_activity():
	var target_global = _attack_origin_raycast.global_transform * _attack_origin_raycast.target_position
	var cast_dir = (target_global - _component.global_position).normalized()
	
	_component.apply_force(component_force * cast_dir)

func mark_active():
	_component.init(ttl, name, ACTIVITY_ID)
	launch_activity()
	
	_component = null
	
func init(player_forward: Node3D):
	if not _attack_origin_raycast:
		_attack_origin_raycast = player_forward.get_node(Activities.ATTACK_ORIGIN_RAYCAST_NAME)
	
	# TODO: create queue so that they can be reused or killed without causing problems.	
	_component = _component_scene.instantiate()
	component_spawn_point.add_child(_component, true)

	_component.global_position = to_global(_attack_origin_raycast.position)
	_component.linear_velocity = Vector3.ZERO

func _ready():
	# TODO: if we tie in animations with this node, we may have to undo this
	# Don't run on clients
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
