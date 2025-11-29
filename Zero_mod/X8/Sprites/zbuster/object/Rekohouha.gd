extends SimplePlayerProjectile

var hitbox_upleft = Vector2(-17, -32)
var hitbox_downright = Vector2(17, 32)
var hitbox_damage = 20
var hitbox_damage_boss = 10
var hitbox_damage_weakness = 10
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
		hitbox_upleft = Vector2(-17, -32)
		hitbox_downright = Vector2(17, 32)
		hitbox_damage = 40
		hitbox_damage_boss = 20
		hitbox_damage_weakness = 20
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	elif CharacterManager.black_zero_armor:
		hitbox_upleft = Vector2(-17, -32)
		hitbox_downright = Vector2(17, 32)
		hitbox_damage = 24
		hitbox_damage_boss = 12
		hitbox_damage_weakness = 12
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	else:
		hitbox_upleft = Vector2(-17, -32)
		hitbox_downright = Vector2(17, 32)
		hitbox_damage = 20
		hitbox_damage_boss = 10
		hitbox_damage_weakness = 10
		hitbox_break_guard_value = 0.25
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1

func _Update(delta: float) -> void :
	._Update(delta)
	set_horizontal_speed(0)
	set_vertical_speed(-420)

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

