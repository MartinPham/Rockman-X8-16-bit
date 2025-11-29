extends FallZero
class_name SaberZeroJump
export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")
var current_hitbox = null
var hitbox_upleft = Vector2(0, 0)
var hitbox_downright = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value = 0.4
var hitbox_break_guards: bool = false
var hitbox_rehit_time = 0.05

var hitbox_upgraded: bool = false
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1

var deflectable: bool = false

onready var animatedSprite = character.get_node("animatedSprite")
onready var saber_sound = get_node("saber")

var current_weapon_index: = 0
var weapons = []
var current_weapon
var _listening_to_inputs_start: bool = true
var interrupted_cutscene: bool = false
var slashing: bool = false
var slashes = 0
var landed: bool = false

var vertical_last = 0

var input_buffer = []
var buffer_window_threshold = 2


onready var swordwave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/swordwave.tscn")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
var creator: Node2D
onready var swordwave_sound: AudioStreamPlayer = $swordwave
var shot_time = 0
var last_direction: = 1

func reset_hitbox():
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.4
	hitbox_break_guards = false
	hitbox_rehit_time = 0.05
	
func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2):
	current_hitbox = saber_hitbox.instance()
	add_child(current_hitbox)
	var facing_direction = get_facing_direction()
	if facing_direction == - 1:
		var temp_upleft = Vector2( - _hitbox_downright.x, _hitbox_upleft.y)
		var temp_downright = Vector2( - _hitbox_upleft.x, _hitbox_downright.y)
		current_hitbox.set_hitbox_corners(temp_upleft, temp_downright)
	else:
		current_hitbox.set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
		
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guard_damage = hitbox_break_guard_value * hitbox_extra_break_guard_value
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.saber_rehit = hitbox_rehit_time
	current_hitbox.upgraded = hitbox_upgraded
	
	current_hitbox.deflectable = deflectable

func hitbox_and_position():
	hitbox_damage = 4
	hitbox_damage_boss = 4
	hitbox_damage_weakness = 24
	if animatedSprite.animation == "saber_jump":
		if animatedSprite.frame >= 3 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2( - 29, - 31)
			hitbox_downright = Vector2(55, 15)
			spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_land":
		if animatedSprite.frame >= 3 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2( - 22, - 26)
			hitbox_downright = Vector2(60, 20)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			
	if animatedSprite.animation == "saber_rasetsusen":
		if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
			hitbox_upleft = Vector2( - 4, - 51)
			hitbox_downright = Vector2(42, -3)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
			hitbox_upleft = Vector2( 9, - 47)
			hitbox_downright = Vector2(48, 12)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2( - 6, - 27)
			hitbox_downright = Vector2(46, 31)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2( -21, 3)
			hitbox_downright = Vector2(25, 38)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 5 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( - 42, - 13)
			hitbox_downright = Vector2(4, 35)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 6 and animatedSprite.frame < 7:
			hitbox_upleft = Vector2( - 48, - 25)
			hitbox_downright = Vector2(-8, 34)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 7 and animatedSprite.frame < 8:
			hitbox_upleft = Vector2( - 46, - 44)
			hitbox_downright = Vector2(5, 14)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 8 and animatedSprite.frame < 9:
			hitbox_upleft = Vector2( - 24, - 50)
			hitbox_downright = Vector2(21, - 16)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 9 and animatedSprite.frame < 10:
			hitbox_upleft = Vector2( - 4, - 51)
			hitbox_downright = Vector2(42, -3)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 10 and animatedSprite.frame < 11:
			hitbox_upleft = Vector2( 9, - 47)
			hitbox_downright = Vector2(48, 12)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			
	reset_hitbox()

func end_saber_state():
	if animatedSprite.animation == "saber_jump" or animatedSprite.animation == "saber_land":
		return animatedSprite.frame >= 8
	elif animatedSprite.animation == "saber_rasetsusen":
		return animatedSprite.frame >= 11
	else:
		return animatedSprite.frame >= 0

func is_in_buffer_window() -> bool:
	if animatedSprite.animation == "saber_jump":
		if animatedSprite.frame >= 6 - buffer_window_threshold:
			return true
	return false

func should_add_saber_combo():
	if animatedSprite.animation == "saber_jump":
		return animatedSprite.frame >= 6
	else:
		return false

func set_saber_animations():
	if character.is_on_floor():
		animatedSprite.animation = "saber_land"
		animatedSprite.frame = 0
		saber_sound.play()
	if not character.is_on_floor():
		if CharacterManager.awakened_zero_armor and character.get_action_pressed("move_up"):
			create()
		elif CharacterManager.extra_saber_01 and CharacterManager.extra_saber_combo and character.get_action_pressed("select_special") and character.get_action_pressed("move_up") and not CharacterManager.awakened_zero_armor:
			if use_genmu.has_ammo_10():
				create()
				use_genmu.reduce_ammo(CharacterManager.buster_base_energy * 0.5)
		elif CharacterManager.extra_saber_combo and not character.get_action_pressed("select_special") and character.get_action_pressed("move_up"):
			animatedSprite.animation = "saber_rasetsusen"
			animatedSprite.frame = 0
			saber_sound.play()
		else:
			animatedSprite.animation = "saber_jump"
			animatedSprite.frame = 0
			saber_sound.play()


func create() -> void :
	last_direction = character.get_facing_direction()
	animatedSprite.animation = "saber_rasetsusen"
	animatedSprite.frame = 0
	swordwave_sound.play()
	create_rasetsusen()
	Tools.timer(0.03, "create_rasetsusen", self)
	Tools.timer(0.06, "create_rasetsusen", self)
	Tools.timer(0.09, "create_rasetsusen", self)
	Tools.timer(0.12, "create_rasetsusen", self)
	Tools.timer(0.15, "create_rasetsusen", self)
	Tools.timer(0.18, "create_rasetsusen", self)

func create_rasetsusen() -> void :
	if shot_time == 0:
		create_swordwave(global_position,  10, 300, 0, 0, 0)
	if shot_time == 1:
		create_swordwave(global_position,  10, 259, 150, 0.5235987755, 0)
	if shot_time == 2:
		create_swordwave(global_position,  10, 150, 259, 1.0471975511, 0)
	if shot_time == 3:
		create_swordwave(global_position,  10, 0, 300, 1.5707963267, 0)
	if shot_time == 4:
		create_swordwave(global_position,  10, -150, 259, 2.0943951023, 0)
	if shot_time == 4:
		create_swordwave(global_position,  10, -259, 150, 2.6179938779, 0)
	if shot_time == 6:
		create_swordwave(global_position,  10, -300, 0, 3.1415926535, 0)
	shot_time += 1

func create_swordwave(ground_position,  damage_value, xspeed: float, yspeed: float, rotation_degress, rotation_speed) -> void :
	var instance = swordwave.instance()
	ground_position.y += -9
	instance.damage =  damage_value * 2
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value
	instance.tracking = true
	instance.rotation = rotation_degress * last_direction
	instance.scale.x = last_direction
	instance.scale.y = last_direction
	instance.set_horizontal_speed(xspeed * last_direction)
	instance.set_vertical_speed(yspeed)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func _StartCondition() -> bool:
	if CharacterManager.extra_saber_combo and CharacterManager.extra_saber_04:
		if character.get_action_pressed("move_down") and not character.get_action_pressed("move_left") and not character.get_action_pressed("move_right"):
			return false
	var _animation = get_parent().get_animation()
	for _ani in character.saber_animations:
		if _animation == "saber_dash":
			return false
		if _animation == "juuhazan":
			return false
		if _animation == "rasetsusen":
			return false
		if _animation == "youdantotsu":
			return false
		if _animation == "enkoujin":
			return false
		if _animation == "raikousen":
			return false
		if _animation == "ryuenjin":
			return false
		if _animation == "hyouryuushou":
			if animatedSprite.frame < 23:
				return false
	if not executing:
		if not character.is_on_floor():
			vertical_last = character.velocity.y
			return true
	return false
	
func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if end_saber_state():
			return true
	else:
		return true
	return false

func _Setup() -> void :
	if CharacterManager.player_character == "Zero" and CharacterManager.awakened_zero_armor:
		dashjump_speed = 400
	else:
		dashjump_speed = 300
	shot_time = 0
	landed = false
	if vertical_last != 0:
		character.velocity.y = vertical_last
	set_saber_animations()
	if character.dashjumps_since_jump > 0:
		horizontal_velocity = dashjump_speed
		character.dashjump_signal()
	else:
		horizontal_velocity = 90

func _Update(_delta: float) -> void :
	hitbox_and_position()
	
	if is_in_buffer_window() and character.get_action_just_pressed(actions[0]):
		input_buffer.append(actions[0])
	
	if should_add_saber_combo() and input_buffer.size() > 0:
		input_buffer.pop_front()
		set_saber_animations()

	process_gravity(_delta)
	
	if character.dashfall:
		set_movement_and_direction(dashjump_speed, _delta)
	else:
		set_movement_and_direction(horizontal_velocity, _delta)
		
	var animation_frame = animatedSprite.frame
	if character.is_on_floor():
		if not landed:
			animatedSprite.animation = "saber_land"
			animatedSprite.frame = animation_frame
			landed = true
		set_movement_no_direction(0)
		update_bonus_horizontal_only_conveyor()

	if animatedSprite.animation == "saber_rasetsusen":
		set_horizontal_speed(0)
		set_vertical_speed(0)

func change_animation_if_falling(_s) -> void :
	animatedSprite.animation = "fall"

func _Interrupt():
	slashes = 0
	input_buffer = []
	var _fall_node = character.get_node("Fall")
	_fall_node.horizontal_velocity = horizontal_velocity
	if character.is_on_floor():
		animatedSprite.animation = "recover"
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()

func Initialize() -> void :
	executing = true
	timer = 0
	last_time_used = get_time()
	character.executing_moves.append(self)
	emit_signal("executed")
	play_sound_on_initialize()
	play_animation_on_initialize()

func BeforeEveryFrame(_delta: float) -> void :
	pass
	

