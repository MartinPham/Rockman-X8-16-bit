extends SimplePlayerProjectile
var tracking: bool = false


var track_timer: = 0.0
export  var tracking_time: = 0.1
const minimum_time_between_recharges: = 0.1

const speed: = 600.0
var hitbox_upleft = Vector2(-32, -72)
var hitbox_downright = Vector2(32, 72)
var hitbox_damage = 120
var hitbox_damage_boss = 120
var hitbox_damage_weakness = 120
var hitbox_break_guard_value = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time = 0.1

const bypass_shield: = true
const continuous_damage := true
const destroyer := true

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
		hitbox_upleft = Vector2(-32, -72)
		hitbox_downright = Vector2(32, 72)
		hitbox_damage = 240
		hitbox_damage_boss = 240
		hitbox_damage_weakness = 240
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	elif CharacterManager.black_zero_armor:
		hitbox_upleft = Vector2(-32, -72)
		hitbox_downright = Vector2(32, 72)
		hitbox_damage = 144
		hitbox_damage_boss = 144
		hitbox_damage_weakness = 144
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
	else:
		hitbox_upleft = Vector2(-32, -72)
		hitbox_downright = Vector2(32, 72)
		hitbox_damage = 120
		hitbox_damage_boss = 120
		hitbox_damage_weakness = 120
		hitbox_break_guard_value = 0.25
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1

func _Update(delta: float) -> void :
	._Update(delta)
	CharacterManager.set_zeroX8_colors(animatedSprite)
	if CharacterManager.custom_zero_armor:
		trackup(delta)
	else:
		track()

func track():
	set_horizontal_speed(600 * get_facing_direction())
	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
	if facing_direction == - 1:
		scale.y=-1
	else:
		scale.y=1

func trackup(delta: float) -> void :
	timer += delta
	set_horizontal_speed(600 * get_facing_direction())
	set_vertical_speed(0)
	#set_vertical_speed(420 * cos(delta * 90))
	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
	if facing_direction == - 1:
		scale.y=-1
	else:
		scale.y=1

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
