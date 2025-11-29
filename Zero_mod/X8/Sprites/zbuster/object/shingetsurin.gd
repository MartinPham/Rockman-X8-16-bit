extends SimplePlayerProjectile
onready var left_tracker: Area2D = $left_tracker
onready var right_tracker: Area2D = $right_tracker
onready var all_tracker: Area2D = $all_tracker
var tracking: bool = false

var hitbox_rehit_time = 0.1

const bypass_shield: = true

var hitfirsttime_casted: bool = false

func reset_hitbox():
	hitbox_rehit_time = 1.4

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

func get_target_from_facing_direction_all() -> Node2D:
	var all_check1
	var all_check2
	if get_facing_direction() > 0:
		all_check1 = all_tracker
		all_check2 = all_tracker
	else:
		all_check1 = all_tracker
		all_check2 = all_tracker

	var target = all_check1.get_closest_target()
	
	
	return target

func track():
	var target = get_target_from_facing_direction_first()
	if target:
		var dir: = Tools.get_angle_between(target, self)
		set_horizontal_speed(280 * dir.x)
		set_vertical_speed(280 * dir.y)
		if facing_direction == - 1:
			scale.x=-1
		else:
			scale.x=1
	else:
		set_horizontal_speed(280 * get_facing_direction())
		if facing_direction == - 1:
			scale.x=-1
		else:
			scale.x=1
	tracking = true
	hitfirsttime_casted = false
	track2()

func track2():
	if not hitfirsttime_casted:
		yield(get_tree().create_timer(0.7), "timeout")
		set_horizontal_speed(0)
		set_vertical_speed(0)
		tracking = true
		hitfirsttime_casted = true
		track3()
	else:
		pass

func _OnHit(_target_remaining_HP) -> void :
	if not hitfirsttime_casted:
		hitfirsttime_casted = true
		yield(get_tree().create_timer(0.15), "timeout")
		set_horizontal_speed(0)
		set_vertical_speed(0)
		tracking = true
		track3()
	else:
		pass

func deflect(_var) -> void :
	pass

func track3():
	yield(get_tree().create_timer(1.5), "timeout")
	var target = get_target_from_facing_direction_all()
	if target:
		var dir: = Tools.get_angle_between(target, self)
		set_horizontal_speed(280 * dir.x)
		set_vertical_speed(280 * dir.y)
		if facing_direction == - 1:
			scale.x=-1
		else:
			scale.x=1
	else:
		set_horizontal_speed(280 * get_facing_direction())
		if facing_direction == - 1:
			scale.x=-1
		else:
			scale.x=1
	tracking = true

func _Update(delta: float) -> void :
	._Update(delta)
	if not tracking:
		hitfirsttime_casted = false
		track()

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
