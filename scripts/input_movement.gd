class_name MovementInput extends Node

var motion_input := Vector2.ZERO
var jump_input := 0.0
var run_input := false

func _ready():
	if not is_multiplayer_authority():
		return

func _process(delta):
	if not is_multiplayer_authority():
		return
	
	motion_input = Input.get_vector("left", "right", "forward", "backward")
	
	jump_input = Input.get_action_strength("jump")
	
	run_input = Input.is_action_pressed("run")
