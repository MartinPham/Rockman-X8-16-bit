extends GenericProjectile
class_name SimpleProjectile

export  var speed: float = 160.0

onready var hitparticle: Sprite = $"Hit Particle"

var emitted: bool = false


func _Setup() -> void :
	set_horizontal_speed(speed * get_direction())

func _OnHit(_target_remaining_HP) -> void :
	if not emitted:
		disable_visuals()
		deactivate()
		hitparticle.emit()
		emitted = true
