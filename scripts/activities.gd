extends Node

# Autoloader

const ATTACK_ORIGIN_RAYCAST_NAME = "AttackOriginRaycast"
static var NO_ACTIVITY = Activity.new(0, "noop", "noop", 0, 0, "noop", "noop")

# TODO: Load from config, probably validate with database
var _available_activities: Dictionary = {
	# id, friendly, base_dmg, base_cd, animation on use, animation on hit
	0: NO_ACTIVITY,
	1: Activity.new(1, "PunchActivity", "Punch", 10.0, 1.0, "punch", "TODO"),
	2: Activity.new(2, "Spell1Activity", "Spell", 5.0, 1.75, "attack", "TODO"),
	3: Activity.new(3, "LongRangeSpike", "Spell", 5.0, 1.75, "attack", "TODO")
}

func get_activity(id: int) -> Activity:
	return _available_activities[id]

func get_no_activity() -> Activity:
	return NO_ACTIVITY
