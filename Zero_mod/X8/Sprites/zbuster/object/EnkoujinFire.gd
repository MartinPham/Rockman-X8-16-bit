extends SimplePlayerProjectile
onready var mini_projectile: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/EnkoujinFireWall.tscn")

onready var vanish: AudioStreamPlayer2D = $vanish
onready var fire_1: Particles2D = $animatedSprite/fire1
onready var fire_2: Particles2D = $animatedSprite/fire2
onready var fire_3: Particles2D = $animatedSprite/fire3

var exploded: = false
var speed: int = 300

const bypass_shield: = true
const continuous_damage := false
const destroyer := false

func _ready():
	add_to_group("Player Projectile")
	set_horizontal_speed(speed)

func _Update(delta: float) -> void :
	._Update(delta)
	if is_on_wall():
		if not exploded:
			explode()
	if not exploded and get_horizontal_speed() <= 100 and get_horizontal_speed() >= - 100:
		explode()

func explode() -> void :
	fire_1.emitting = false
	fire_2.emitting = false
	fire_3.emitting = false
	exploded = true
	animatedSprite.play("enkoujinwaveexplode")
	disable_damage()
	Tools.timer(1, "destroy", self)
	vanish.play_rp()
	set_horizontal_speed(0)
	create_mini_projectile()

func create_mini_projectile():
	var projectile = mini_projectile.instance()
	get_tree().current_scene.add_child(projectile, true)
	projectile.set_global_position(global_position)
	projectile.set_creator(creator)
	if speed > 0:
		projectile.initialize(-1)
		projectile.scale.x = -1
		projectile.scale.y = -1
	else:
		projectile.initialize(1)
		projectile.scale.x = 1
		projectile.scale.y = 1
	projectile.damage = 10
	projectile.damage_to_bosses = 4
	projectile.damage_to_weakness = 25
	projectile.set_vertical_speed( - 250)
	projectile.collision_mask = 1

func _OnHit(_target_remaining_HP) -> void :
	pass

func deflect(_var) -> void :
	pass

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

