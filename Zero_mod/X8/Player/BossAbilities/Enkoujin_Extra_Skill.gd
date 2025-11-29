extends FallZero
class_name SaberEnkoujinExtraX8

export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")

onready var animatedSprite: = character.get_node("animatedSprite")
onready var saber_sound: = get_node("saber")

var current_hitbox = null
var hitbox_name: String = "Enkoujin_Extra"
var hitbox_upward_movement: int = 100
var hitbox_upleft = Vector2(0, 0)
var hitbox_downright = Vector2(0, 0)
var hitbox_damage: float = 0
var hitbox_damage_boss: float = 0
var hitbox_damage_weakness: float = 0
var hitbox_break_guard_value: float = 0.4
var hitbox_break_guards: bool = false
var hitbox_rehit_time: float = 0.05
var hitbox_upgraded: bool = false
var hitbox_extra_damage: float = 1
var hitbox_extra_damage_boss: float = 1
var hitbox_extra_damage_weakness: float = 1
var hitbox_extra_break_guard_value: float = 1
var deflectable: bool = false
var deflectable_type: int = 0
var only_deflect_weak: bool = false

var ending_saber_state: bool = false
var landed: bool = false
var cancel_time: float = 0.3
var hitbox_timer: float = 0.0
var hitbox_time: float = 0.05
var landing_frame: int = 9
var loop_frame: int = 8
var loop_start_frame: int = 4


func _ready() -> void :
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func reset_hitbox() -> void :
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25

func set_hitbox_corners(upleft: Vector2, downright: Vector2) -> RectangleShape2D:
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	return shape

func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2):
	current_hitbox = saber_hitbox.instance()

	var collision_shape_node = current_hitbox.get_node("collisionShape2D")
	var deflection_shape_node = current_hitbox.get_node("area2D/collisionShape2D")
	if collision_shape_node == null:
		return
	else:
		current_hitbox.collision_shape = collision_shape_node
	if deflection_shape_node == null:
		return
	else:
		current_hitbox.deflection_shape = deflection_shape_node
	
	var hitbox_shape = set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
	var hitbox_position = Vector2(0, 0)
	
	var facing_direction = get_facing_direction()
	if facing_direction == - 1:
		var temp_upleft = Vector2( - _hitbox_downright.x, _hitbox_upleft.y)
		var temp_downright = Vector2( - _hitbox_upleft.x, _hitbox_downright.y)
		hitbox_shape = set_hitbox_corners(temp_upleft, temp_downright)
		hitbox_position = (temp_upleft + temp_downright) / 2
	else:
		hitbox_shape = set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
		hitbox_position = (_hitbox_upleft + _hitbox_downright) / 2
	
	current_hitbox.collision_shape.shape = hitbox_shape
	current_hitbox.deflection_shape.shape = hitbox_shape
	current_hitbox.position = hitbox_position
	
	add_child(current_hitbox)
		
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guard_damage = hitbox_break_guard_value * hitbox_extra_break_guard_value
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.saber_rehit = hitbox_rehit_time
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.deflectable = deflectable
	current_hitbox.deflectable_type = deflectable_type
	current_hitbox.only_deflect_weak = only_deflect_weak

func hitbox_and_position() -> void :
	hitbox_damage = 10
	hitbox_damage_boss = 4
	hitbox_damage_weakness = 30
	hitbox_break_guards = true
	if animatedSprite.animation == "saber_shot_fast1":
		if character.saber_node.current_weapon.name == "Saber":
			if animatedSprite.frame >= 4 and animatedSprite.frame < 14:
				hitbox_upleft = Vector2( - 2, - 13)
				hitbox_downright = Vector2(30, 40)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

func should_go_down() -> bool:
	return animatedSprite.frame >= loop_start_frame

func end_saber_state() -> bool:
	if character.is_on_floor():
		return ending_saber_state
	return false

func repeat_animation() -> void :
	if animatedSprite.frame >= loop_frame:
		animatedSprite.frame = loop_start_frame

func set_saber_animations() -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "saber_shot_fast1"
		animatedSprite.frame = 0
	saber_sound.play()

func _StartCondition() -> bool:
	if not CharacterManager.extra_saber_combo:
		return false
	if not CharacterManager.extra_saber_04:
		return false
	if not character.get_action_pressed("move_down"):
		return false
	if character.get_action_pressed("move_left") or character.get_action_pressed("move_right"):
		return false
	if not character.saber_node.current_weapon.name == "Saber":
		return false
	var _animation = get_parent().get_animation()
	for _ani in character.saber_animations:
		if _animation == "saber_dash":
			return false
		if _animation == "saber_jump":
			return false
		if _animation == "saber_jump_1":
			return false
		if _animation == "saber_jump_2":
			return false
		if _animation == "tenshouha":
			return false
		if _animation == "juuhazan":
			return false
		if _animation == "rasetsusen":
			return false
		if _animation == "raikousen":
			return false
		if _animation == "youdantotsu":
			return false
		if _animation == "hyouryuushou":
			return false
		if _animation == "hyouryuushou_air":
			return false
		if _animation == "genmuzero":
			return false
		if _animation == "genmuzeroair":
			return false
	if not executing:
		if not character.is_on_floor():
			return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not character.is_on_floor():
		if not character.get_action_pressed("fire") and timer >= cancel_time:
			return true
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if end_saber_state():
			return true
	else:
		return true
	return false

func _Setup() -> void :
	landed = false
	set_saber_animations()
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	character.dashjumps_since_jump = 0
	ending_saber_state = false

func _Update(delta: float) -> void :
	if timer < cancel_time:
		timer += delta
	hitbox_time = 0.05
	if hitbox_timer < hitbox_time:
		hitbox_timer += delta
	else:
		hitbox_timer = 0
		hitbox_and_position()
		
	if not landed:
		set_movement_no_direction(horizontal_velocity)
		repeat_animation()
		if should_go_down():
			character.set_vertical_speed(jump_velocity)
		var animation_frame = animatedSprite.frame
		if character.is_on_floor():
			animatedSprite.frame = landing_frame
			landed = true
	
	else:
		process_gravity(delta)
		force_movement(0)
		update_bonus_horizontal_only_conveyor()

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()

func BeforeEveryFrame(_delta: float) -> void :
	pass
