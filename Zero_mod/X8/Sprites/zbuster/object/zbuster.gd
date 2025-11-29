extends SimplePlayerProjectile
var tracking: bool = false

var hitbox_upleft = Vector2(-32, -17)
var hitbox_downright = Vector2(32, 17)
var hitbox_damage = 10
var hitbox_damage_boss = 3
var hitbox_damage_weakness = 3
var hitbox_break_guard_value = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time = 0.1

const bypass_shield: = true

func reset_hitbox():
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25
	hitbox_break_guards = true
	hitbox_rehit_time = 0.1

func hitbox_and_position():
	if CharacterManager.awakened_zero_armor:
		hitbox_upleft = Vector2(-32, -17)
		hitbox_downright = Vector2(32, 17)
		hitbox_damage = 20
		hitbox_damage_boss = 6
		hitbox_damage_weakness = 6
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	elif CharacterManager.black_zero_armor:
		hitbox_upleft = Vector2(-32, -17)
		hitbox_downright = Vector2(32, 17)
		hitbox_damage = 12
		hitbox_damage_boss = 3.6
		hitbox_damage_weakness = 3.6
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	else:
		hitbox_upleft = Vector2(-32, -17)
		hitbox_downright = Vector2(32, 17)
		hitbox_damage = 10
		hitbox_damage_boss = 3
		hitbox_damage_weakness = 3
		hitbox_break_guard_value = 0.25
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1

func _Update(delta: float) -> void :
	._Update(delta)
	set_horizontal_speed(420 * get_facing_direction())
	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
	if animatedSprite.frame >= 93:
		animatedSprite.frame = 3

func _OnHit(_target_remaining_HP) -> void :
	pass

func deflect(_var) -> void :
	pass

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

