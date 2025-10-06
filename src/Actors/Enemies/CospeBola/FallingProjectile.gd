extends SimpleProjectile

var life_duration: = 1.0

func _Update(delta: float) -> void :
	process_gravity(delta)
	if timer > life_duration:
		destroy()
