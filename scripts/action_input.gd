class_name ActionInput extends Node

# TODO: I think we need a way to detect which type of action we want to perform
# - targeting a mob/player is a attack
# - clicking on item/door is an interaction
# TODO: not sure we should keep _activity_handler ref for only current_activity.
# - We could probably just assume it's good and play animation. More advanced 
# setup/refactor would be needed to support cancelling started animations...

var _keybinding_activity_map: Dictionary = {
	"q": 1,
	"e": 2
}

var _activity_handler: ActivityHandler

func _current_action_driven_activity(activity) -> Activity:
	# Don't process for inputs unless something was pressed
	if Input.is_anything_pressed():
		activity = _key_bound_activity(activity)
		# TODO: mouse inputs can be put here, but add conditional that activity is still NO_ACTIVITY 
		# otherwise you have one and don't need to process mouse click...

	return activity

func _key_bound_activity(activity):
	# Loop through all available key bindings and check for the one just pressed
	# NOTE: this is separate from movement, so we can afford to break once found. 
	# May need refactor once multi-key support needed for actions.
	for key_binding in _keybinding_activity_map.keys():
		if Input.is_action_just_pressed(key_binding):
			var action = _is_current_action_active(_keybinding_activity_map[key_binding])
			if action != _activity_handler.NO_ACTION:
				activity = Activities.get_activity(action)
				break # We don't need to keep looking for inputs, once was found
	return activity
	
func _is_current_action_active(action_input) -> int:
	# Prevents player from being making additional action until it has cleared
	if _activity_handler._current_activity_id == _activity_handler.NO_ACTION:
		return action_input
	else:
		print("I cannot do that yet...")
		return _activity_handler.NO_ACTION

func process_input() -> Activity:
	var activity = Activities.NO_ACTIVITY

	if is_multiplayer_authority():
		activity = _current_action_driven_activity(activity)
		
	return activity

func init(activity_handler: ActivityHandler):
	_activity_handler = activity_handler
