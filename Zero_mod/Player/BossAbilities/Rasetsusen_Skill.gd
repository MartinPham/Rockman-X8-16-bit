extends FallZero
class_name SaberRasetsusen

export  var damage: float = 2.0
export  var damage_boss: float = 2.0
export  var damage_weakness: float = 24.0
export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Rasetsusen_Hitbox.tscn")

onready var darkarrow: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/DarkArrow.tscn")
var creator: Node2D

onready var animatedSprite: = character.get_node("animatedSprite")
onready var saber_sound: = get_node("saber")

var current_hitbox = null
var hitbox_name: String = "Rasetsusen"
var hitbox_radius: float = 96
var hitbox_inner_radius: float = 0
var hitbox_upleft_corner: Vector2 = Vector2( - hitbox_radius, - hitbox_radius)
var hitbox_downright_corner: Vector2 = Vector2(hitbox_radius, hitbox_radius)
var hitbox_upleft: Vector2 = Vector2(0, 0)
var hitbox_downright: Vector2 = Vector2(0, 0)
var hitbox_damage: float = 0.0
var hitbox_damage_boss: float = 0.0
var hitbox_damage_weakness: float = 0.0
var hitbox_break_guard_value: float = 0.5
var hitbox_break_guards: bool = false
var hitbox_rehit_time: float = 0.15
var hitbox_upgraded: bool = false
var hitbox_extra_damage: float = 0.0
var hitbox_extra_damage_boss: float = 0.0
var hitbox_extra_damage_weakness: float = 0.0
var hitbox_extra_break_guard_value: float = 0.0
var deflectable: bool = false
var deflectable_type: int = 0
var only_deflect_weak: bool = false

var ending_saber_state: bool = false
var slashing: bool = false
var slashes: int = 0
var landed: bool = false

var max_time: float = 2.0
var fly_up: bool = false
var falling_down: bool = false
var horizontal_speed: float = horizontal_velocity
var cast_time_max: float = 0.35
var cast_time: float = 0.0
var vertical_last: float = 0.0

var create_dark_arrow: bool = false

func _ready() -> void :
	saber_sound.stream.loop = true
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func reset_hitbox() -> void :
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.5
	hitbox_break_guards = false

func spawn_hitbox(position: Vector2, _hitbox_upleft: Vector2, _hitbox_downright: Vector2) -> void :
	
	current_hitbox = saber_hitbox.instance()
	add_child(current_hitbox)
	
	var size = _hitbox_downright - _hitbox_upleft
	var radius = min(size.x, size.y) / 2

	current_hitbox.set_hitbox(position, radius)
	current_hitbox.name = hitbox_name
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guard_damage = hitbox_break_guard_value * hitbox_extra_break_guard_value
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.saber_rehit = hitbox_rehit_time
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.inner_radius = hitbox_inner_radius
	current_hitbox.deflectable = deflectable
	current_hitbox.deflectable_type = deflectable_type
	current_hitbox.only_deflect_weak = only_deflect_weak



func hitbox_and_position() -> void :
	hitbox_damage = damage
	hitbox_damage_boss = damage_boss
	hitbox_damage_weakness = damage_weakness
	if animatedSprite.animation == "rasetsusen":
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_upleft = Vector2( - hitbox_radius, - hitbox_radius)
			hitbox_downright = Vector2(hitbox_radius, hitbox_radius)
			spawn_hitbox(Vector2(0, - 8), hitbox_upleft, hitbox_downright)
			if not create_dark_arrow:
				create_dark_arrow = true
				Tools.timer(0.3, "reset_dark_arrow", self)
				if CharacterManager.awakened_zero_armor:
					create_darkarrowcustom(global_position)
	reset_hitbox()

func reset_dark_arrow() -> void :
	create_dark_arrow = false

func create_darkarrowcustom(ground_position) -> void :
	var instance = darkarrow.instance()
	ground_position.y += -9
	instance.damage = 20
	instance.damage_to_bosses = 10
	instance.damage_to_weakness = 10
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func end_saber_state() -> bool:
	return animatedSprite.frame >= animatedSprite.frames.get_frame_count("rasetsusen") - 1

func should_add_saber_combo() -> bool:
	return ending_saber_state

func reset_saber_animation() -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "rasetsusen"
		animatedSprite.frame = 1
		ending_saber_state = false

func _StartCondition() -> bool:
	if not character.Rasetsusen:
		return false
	if character.Rasetsusen_used:
		return false
	if character.get_action_pressed("move_up"):
		return false
	if character.get_action_pressed("move_down"):
		return false
	var _animation = get_parent().get_animation()
	for _ani in character.saber_animations:
		if _animation == "saber_dash":
			return false
		if _animation == "saber_jump":
			return false
		if _animation == "youdantotsu":
			return false
		if _animation == "youdantotsua":
			return false
		if _animation == "youdantotsuawaken":
			return false
		if _animation == "youdantotsuawakena":
			return false
		if _animation == "enkoujin":
			return false
		if _animation == "juuhazan":
			return false
		if _animation == "raikousen":
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
			vertical_last = character.velocity.y
			return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if not _animation == "rasetsusen":
		return true
	if not character.get_action_pressed(actions[0]):
		saber_sound.stop()
		return true
	if character.is_on_floor():
		return true
	return false

func _Setup() -> void :
	if CharacterManager.player_character == "Zero" and CharacterManager.awakened_zero_armor:
		dashjump_speed = 400
	else:
		dashjump_speed = 300

	saber_sound.play()
	horizontal_velocity = 0
	horizontal_speed = 0
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	character.dashfall = false
	character.Rasetsusen_used = true
	fly_up = false
	falling_down = false
	timer = 0.0
	character.dashjumps_since_jump = 0
	cast_time = 0.0
	ending_saber_state = false

func _Update(_delta: float) -> void :
	timer += _delta
	if fly_up:
		cast_time += _delta


	if not falling_down:
		if (character.get_action_pressed("move_down") and timer >= 0.2 or timer >= max_time) and not fly_up:
			falling_down = true
			timer = max_time
			character.set_vertical_speed(jump_velocity)
			if character.get_action_pressed("move_left") or character.get_action_pressed("move_right"):
				horizontal_speed = dashjump_speed
				character.dashjumps_since_jump = 1
		if character.get_action_pressed("move_up"):
			falling_down = true
			character.set_vertical_speed( - jump_velocity)
			fly_up = true
			if character.get_action_pressed("move_left") or character.get_action_pressed("move_right"):
				horizontal_speed = dashjump_speed
				character.dashjumps_since_jump = 1
		set_movement_and_direction(0, _delta)
	else:
		horizontal_velocity = horizontal_speed
		if fly_up:
			if cast_time < cast_time_max:
				character.set_vertical_speed( - jump_velocity)
			else:
				process_gravity(_delta)
	force_movement(horizontal_speed)
	hitbox_and_position()
	if should_add_saber_combo():
		if character.get_action_pressed(actions[0]):
			reset_saber_animation()

func change_animation_if_falling(_s) -> void :
	animatedSprite.animation = "fall"

func _Interrupt() -> void :
	slashes = 0
	saber_sound.stop()
	animatedSprite.animation = "fall"
	animatedSprite.rotation_degrees = 0
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
