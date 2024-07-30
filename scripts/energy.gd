class_name Energy extends Node

@export var energy_level: int = 0

const ENERGY_REQUIRED_TO_WIN = 11

func add_energy(energy: int):
	energy_level += energy
	print("Player [%s] received [%s] energy. Now has [%s]" % [get_parent().name, energy, energy_level])

func max_energy_reached():
	print("max energy reached? %s" % energy_level)
	return energy_level >= ENERGY_REQUIRED_TO_WIN

func drain_energy(drain_amount: int):
	if energy_level > 0:
		energy_level -= drain_amount
		print("Player %s was drained down to energy %s" % [get_parent().name, energy_level])
		return drain_amount
	else:
		return 0

func reset():
	energy_level = 0
