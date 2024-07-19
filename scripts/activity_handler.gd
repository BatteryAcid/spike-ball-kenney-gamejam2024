class_name ActivityHandler extends Node

# ASSUMPTION:
# For now we only allow single activity limited by the cooldown of that spell.
# 
# Flow of this class:
# Two entry points:
# 1. activity_request: things the player wants to do
# 2. apply_activity_request: things done to the player from outside sources (other players, boss, mobs, etc)
# 	- These both add Activity to _activity_queue
# - _process_activities_queue pops off the next Activity. If it's...
# 	- "self": sets it to _current_activity, which is then ran by _execute_activity, marks it processed.
# 	- anything else: executes the activity on the player.
#
# The idea is that all Activities are in a queue so that they are processed in order, regardless if it's
# something the player does or done to them. 
#
# -----------------------
# TODO: _process_activities_queue needs refactoring to check for activity type, and not just "self",
# as it only supports attack under "self".
# TODO: As of 4.2, we can't synch complex objects, so we have to sync _current_activity_id along side _current_activity.

# TODO: consider refactoring this to be a queue that player.gd passes in and processes
# - only issue is if the timing of the spells added the the queue was delayed (lag-spike),
# we may be animating spells way in the past, so we'd need a speed up mechanism to catch up.
# Seems like having a synched tick mechanism for everything is required... Although, having a single
# flag for animation may skip some due to lag, but wouldn't really need catchup mechanism, would just miss some... tradeoffs
signal animation_approved_signal

const NO_ACTION: int = -1

@onready var _current_activity_cooldown = $ActionCooldown

@export var player_forward: Node3D
@export var attack_activities: Node3D
@export var hurtbox: Hurtbox

var _activity_queue: Array[Activity] = []
var _current_activity: Activity
var _current_activity_id: int = NO_ACTION

# This executes the current_activity activity
func _execute_activity():
	if _is_current_activity_unprocessed():
		print("Execute action %s" % _current_activity.friendly_name)

		_current_activity.processed = true
		_current_activity_cooldown.wait_time = _current_activity.base_cd
		_current_activity_cooldown.start()
		
		_load_attack()
		
		# Kickoff animation on other clients, not that the activity is executed
		if animation_approved_signal:
			animation_approved_signal.emit(_current_activity.animation_use, _current_activity.base_cd, _current_activity.requester)

func _load_attack():
	if _is_current_activity_set():
		var attack = _get_attack_activity(_current_activity.node_name)
		attack.init(player_forward)
		attack.mark_active()

# Nullify the current action so that it syncs with the client to let them know they can attack again
func _activity_cooldown_timeout():
	print("Activity cooled %s" % _current_activity.friendly_name)
	_set_current_activity(null)

func _process_activities_queue():
	if _is_activity_available_in_queue():
		var activity_to_process: Activity = _activity_queue.pop_front()
		print("Processing activity: %s" % activity_to_process.friendly_name)
		
		# TODO: how do we determine self activity or other? Is that necessary? or do we just take damage/heal/whatever...?
		if activity_to_process.source && activity_to_process.source == "self":
			_set_current_activity(activity_to_process)
			_current_activity.processed = false
			print("Next action [%s | %s]" % [activity_to_process.id, _current_activity.base_dmg])
	
		elif activity_to_process.source && activity_to_process.source == "player": # TODO: should this be damage?
			hurtbox.apply_damage(activity_to_process.base_dmg)
		
# Activities the player does
func activity_requested(requested_activity: int, requester: int):
	# TODO: consider consolidating this check to some autoloader
	if not is_multiplayer_authority():
		return
	
	print("Action requested %s" % requested_activity)
	if _is_requested_activity_valid(requested_activity):
		# Right now we only care that it exists, validation comes at processing time
		var activity_found: Activity = Activities.get_activity(requested_activity)
		
		if activity_found:
			print("Adding action to queue: %s" % activity_found.friendly_name)
			activity_found.requester = requester
			activity_found.source = "self"

			_activity_queue.append(activity_found)

# Activities requested to be applied to player: damage, de/buff, heal, etc
func apply_activity_request(apply_activity_request: int):
	if not is_multiplayer_authority():
		return
		
	print("Apply activity requested %s" % apply_activity_request)
	if _is_requested_activity_valid(apply_activity_request):
		# Right now we only care that it exists, validation comes at processing time
		var activity_found: Activity = Activities.get_activity(apply_activity_request)
		if activity_found:
			print("Adding apply activity to queue: %s" % activity_found.friendly_name)
			#activity_found.requester = requester # TODO: not sure we need requester 
			activity_found.source = "player"

			_activity_queue.append(activity_found)

func _get_attack_activity(attack_name):
	return attack_activities.get_node(attack_name)

# Signal to kickoff animations on other clients
func _set_animation_approved_signal(animation_approved_callback):
	animation_approved_signal.connect(animation_approved_callback)

func _is_activity_available_in_queue() -> bool:
	return _activity_queue && _activity_queue.size() > 0

func _is_current_activity_set() -> bool:
	return _current_activity && _current_activity.id > 0

func _is_current_activity_unprocessed() -> bool:
	return _current_activity && _current_activity.processed == false

func _is_requested_activity_valid(activity: int) -> bool:
	return activity > 0

func _set_current_activity(activity: Activity):
	if activity:
		_current_activity = activity
		# We have to keep this synched with clients so they know if we can use another activity
		_current_activity_id = _current_activity.id
	else: 
		_current_activity = null
		_current_activity_id = NO_ACTION

func _process(delta):
	_process_activities_queue()
	_execute_activity()

func init(animation_approved_callback):
	_set_animation_approved_signal(animation_approved_callback)
