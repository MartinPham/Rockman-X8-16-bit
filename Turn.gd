extends Attack
class_name Turn

export  var new_direction: int = 1


func start_by_signal() -> void :
	if should_start():
		if character.get_facing_direction() != new_direction:
			ExecuteOnce()

func _Setup() -> void :
	character.set_direction(new_direction)
	play_sound(sound)
	._Setup()
