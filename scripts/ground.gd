extends Node3D

@export var water_rise_toggle := true
@export var water_rise_rate: float = 0.05 #0.1
const MAX_WATER_RISE_RATE: float = 0.5
var kill_enabled = true

func _physics_process(delta):
	if water_rise_toggle:
		position += Vector3(0, water_rise_rate * delta, 0)

func _on_area_3d_body_entered(body):
	if is_multiplayer_authority():
		if body is Player && kill_enabled:
			print("hit gound")
			body.kill()

func increase_water_rise_rate(energy_amount):
	if water_rise_rate < MAX_WATER_RISE_RATE:
		water_rise_rate += energy_amount * 0.005
		print("Current rise rate %s" % water_rise_rate)

func reset():
	print("Ground reset")
	position = Vector3.ZERO
	water_rise_rate = 0.05
	kill_enabled = true
