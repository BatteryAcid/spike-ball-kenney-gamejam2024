extends Node3D

# Activity components use this to make sure they don't collide with their client-side players
# that spawned it.
# See spell1_component for example
@export var _player_collision_shape: PhysicsBody3D
