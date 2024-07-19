class_name Hurtbox extends Node

@export var health: Node

func apply_damage(damage_amt: float):
	if health:
		var current_player_health = health.get_health()
		current_player_health -= damage_amt
		health.set_health(current_player_health)
		print("Damage taken: %s, health remaining: %s" % [damage_amt, current_player_health])
