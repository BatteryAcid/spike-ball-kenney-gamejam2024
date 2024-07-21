extends Node3D

# TODO: size/colore cores based on energy amount
# TODO: change color once core is spent
# TODO sync player_charging, change network id, may not need to do this!
@export var energy_amount = 1
@export var power_core_spent := false
@export var _core_label_text := ""
@export var ground_ref: Node3D

@onready var charging_label = $Label3D

var _player_charging: Player

func _physics_process(delta):
	if charging_label:
		charging_label.text = _core_label_text

func _on_area_3d_body_entered(body):
	if is_multiplayer_authority():
		if body is Player and not power_core_spent and not _player_charging:
			print("Player [%s] charging from core %s" % [body.name,energy_amount])
			_player_charging = body
			_core_label_text = "Charging"
			
			$CoreChargeTimer.start(energy_amount)

func _on_core_charge_complete():
	# if player leaves too early they wont receive energy
	if _player_charging:
		power_core_spent = true
		_core_label_text = "Spent"
		_player_charging.energy.add_energy(energy_amount)
		ground_ref.increase_water_rise_rate(energy_amount)

func _on_area_3d_body_exited(body):
	# This is how we mark player left core area
	_player_charging = null
	
	# If player left core area too early, stop timer to prevent them coming back on continuously running timer
	if not power_core_spent:
		_core_label_text = ""
		$CoreChargeTimer.stop()

func reset():
	#print("Core reset")
	power_core_spent = false
	_core_label_text = ""
	_player_charging = null
