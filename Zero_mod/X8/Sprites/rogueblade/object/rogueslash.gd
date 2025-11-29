extends SimplePlayerProjectile
onready var left_tracker: Area2D = $left_tracker
onready var right_tracker: Area2D = $right_tracker
onready var roguewave_sound: AudioStreamPlayer = $roguewave
var tracking: bool = false

var hitbox_damage = 10
var hitbox_damage_boss = 10
var hitbox_damage_weakness = 10
var hitbox_break_guard_value = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time = 0.1

const bypass_shield: = true

func reset_hitbox():
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25
	hitbox_break_guards = true
	hitbox_rehit_time = 0.1

func hitbox_and_position():
	if CharacterManager.awakened_zero_armor:
		hitbox_damage = 20
		hitbox_damage_boss = 20
		hitbox_damage_weakness = 20
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	elif CharacterManager.black_zero_armor:
		hitbox_damage = 12
		hitbox_damage_boss = 12
		hitbox_damage_weakness = 12
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	else:
		hitbox_damage = 10
		hitbox_damage_boss = 10
		hitbox_damage_weakness = 10
		hitbox_break_guard_value = 0.25
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1

func get_target_from_facing_direction_first() -> Node2D:
	var first_check
	var second_check
	if get_facing_direction() > 0:
		first_check = right_tracker
		second_check = left_tracker
	else:
		first_check = left_tracker
		second_check = right_tracker

	var target = first_check.get_closest_target()
	
	
	return target

func track():
	var target = get_target_from_facing_direction_first()
	if target:
		var dir: = Tools.get_angle_between(target, self)
		set_horizontal_speed(600 * dir.x)
		set_vertical_speed(600 * dir.y)
		set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
		if facing_direction == - 1:
			scale.y=-1
		else:
			scale.y=1
	else:
		set_horizontal_speed(600 * get_facing_direction())
		set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
		if facing_direction == - 1:
			scale.y=-1
		else:
			scale.y=1
	tracking = true

func _Update(delta: float) -> void :
	._Update(delta)
	if not tracking:
		track()

func _OnHit(_target_remaining_HP) -> void :
	pass

func deflect(_var) -> void :
	pass

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

func _on_area2D_body_entered(body: Node) -> void :
	if active:
		if body.is_in_group("Enemies") or body.is_in_group("Bosses"):
			return
		if body.active:
			react(body)

func react(body: Node) -> void :
	call_deferred("deflect_projectile", body)

func deflect_projectile(body):
	if body.is_in_group("Enemy Projectile"):
		if body.has_method("_OnHit"):
			body._OnHit(self)
			return
		body.destroy()
