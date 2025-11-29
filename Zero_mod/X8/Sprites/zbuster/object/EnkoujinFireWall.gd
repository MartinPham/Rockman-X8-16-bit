extends GenericProjectile
var exploded: = false
onready var vanish: AudioStreamPlayer2D = $vanish
onready var fire_1: Particles2D = $animatedSprite/fire1
onready var fire_2: Particles2D = $animatedSprite/fire2
onready var fire_3: Particles2D = $animatedSprite/fire3

const bypass_shield: = true
const continuous_damage := false
const destroyer := false

func _ready():
	add_to_group("Player Projectile")

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
	
func _Update(_delta: float) -> void :
	if not exploded and is_on_ceiling():
		explode()
	if not exploded and get_vertical_speed() <= 100 and get_vertical_speed() >= - 100:
		explode()

func _OnHit(_d) -> void :
	pass

func explode() -> void :
	fire_1.emitting = false
	fire_2.emitting = false
	fire_3.emitting = false
	animatedSprite.play("enkoujinwaveexplode")
	exploded = true
	disable_damage()
	Tools.timer(1, "destroy", self)
	vanish.play_rp()
