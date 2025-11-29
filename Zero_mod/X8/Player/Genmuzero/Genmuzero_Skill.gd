extends Movement
class_name Genmuzero

export  var hitbox: Resource = preload("res://Zero_mod/X8/Player/Genmuzero/Genmuzero_Hitbox.tscn")
onready var genmuzerowave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/Genmuzero.tscn")
onready var genmuzerowavecustom: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/Genmuzerocustom.tscn")
export  var upgraded: bool = true

onready var awakenaura: AnimatedSprite = $"../animatedSprite/awakenaura"

onready var animatedSprite: = character.get_node("animatedSprite")
onready var sfx: = $sfx

onready var use_genmu: Node2D = $"../Special/Genmuzero"

var creator: Node2D

var current_hitbox: Object = null
var hitbox_upleft: Vector2 = Vector2(0, 0)
var hitbox_downright: Vector2 = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value: float = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time: float = 0.4

var hitbox_upgraded: bool = true
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1

var sfx_played: bool = false

var start_speed: int = 0
var horizontal_speed: int = start_speed
var damping: float = 0.93
var vertical_start_speed: int = 0
var vertical_speed: int = vertical_start_speed


func reset_hitbox() -> void :
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25
	hitbox_break_guards = true
	hitbox_rehit_time = 0.4

func set_hitbox_corners(upleft: Vector2, downright: Vector2) -> RectangleShape2D:
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	return shape

func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2) -> void :
	current_hitbox = hitbox.instance()
	var collision_shape_node = current_hitbox.get_node("collisionShape2D")
	if collision_shape_node == null:
		return
	else:
		current_hitbox.collision_shape = collision_shape_node
	
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
	current_hitbox.position = hitbox_position
	
	add_child(current_hitbox)
		
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.rehit = hitbox_rehit_time

func hitbox_and_position() -> void :
	hitbox_damage = 64
	hitbox_damage_boss = 64
	hitbox_damage_weakness = 64
	hitbox_break_guards = true
	hitbox_rehit_time = 1
	if animatedSprite.frame >= 8 and animatedSprite.frame < 13:
		hitbox_upleft = Vector2( - 25, - 34)
		hitbox_downright = Vector2(18, - 15)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	if animatedSprite.frame >= 9 and animatedSprite.frame < 13:
		hitbox_upleft = Vector2( - 5, - 39)
		hitbox_downright = Vector2(68, 21)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

func play_sfx() -> void :
	var ground_position = Vector2(global_position.x, global_position.y)
	if animatedSprite.frame >= 10:
		if not sfx_played:
			use_genmu.reduce_ammo(60)
			sfx.play()
			sfx_played = true
			if CharacterManager.awakened_zero_armor and not CharacterManager.awakened_zero_full_power_max:
				if character.is_on_floor():
					create_genmuzerocustom(ground_position + Vector2( 0, - 72 ), 256)
				else:
					create_genmuzerocustom(ground_position + Vector2( 0, 0 ), 256)
			elif CharacterManager.awakened_zero_full_power_max and CharacterManager.awakened_zero_armor:
				if character.is_on_floor():
					create_genmuzerocustom(ground_position + Vector2( 0, - 72 ), 512)
				else:
					create_genmuzerocustom(ground_position + Vector2( 0, 0 ), 512)
			else:
				if character.is_on_floor():
					create_genmuzero(ground_position + Vector2( 0, - 84 ), 128)
				else:
					create_genmuzero(ground_position + Vector2( 0, 0 ), 128)


func create_genmuzero(ground_position, damage_value) -> void :
	var instance = genmuzerowave.instance()
	ground_position.y += 0
	instance.damage = damage_value
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_genmuzerocustom(ground_position, damage_value) -> void :
	var instance = genmuzerowavecustom.instance()
	ground_position.y += 0
	instance.damage = damage_value
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func end_state() -> bool:
	if CharacterManager.player_character == "Zero":
		if CharacterManager.awakened_zero_armor:
			awakenaura.show()
		else:
			awakenaura.hide()
	return animatedSprite.frame >= 19


func invicible_frames() -> bool:
	awakenaura.show()
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame < 23

func movement_frames() -> bool:
	return animatedSprite.frame >= 9 and animatedSprite.frame < 23

func _StartCondition() -> bool:
	if not use_genmu.has_ammo_59():
		character.execute_genmu_zero = false
		return false
	if character.get_action_pressed("move_down") and character.is_on_floor():
		return false
	if character.get_action_pressed("alt_fire"):
		return false
	if not executing:
		if character.execute_genmu_zero:
			return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if end_state():
		return true
	if not animatedSprite.animation == "genmuzero" and not animatedSprite.animation == "genmuzeroair":
		return true
	return false

func _Setup() -> void :
	sfx_played = false
	horizontal_speed = start_speed
	vertical_speed = vertical_start_speed
	update_bonus_horizontal_only_conveyor()
	if character.is_on_floor():
		animatedSprite.animation = "genmuzero"
	else:
		animatedSprite.animation = "genmuzeroair"

func reduce_speed() -> void :
	horizontal_speed = 0

func damp_horizontal_speed(_delta: float) -> void :
	var reference_delta = 1.0 / 120
	var damping_factor = pow(damping, _delta / reference_delta)
	horizontal_speed *= damping_factor

func damp_vertical_speed(_delta: float) -> void :
	var reference_delta = 1.0 / 120
	var damping_factor = pow(damping, _delta / reference_delta)
	vertical_speed *= damping_factor

func _Update(_delta: float) -> void :
	hitbox_and_position()
	play_sfx()
	update_bonus_horizontal_only_conveyor()
	if movement_frames():
		force_movement(horizontal_speed)
		character.set_vertical_speed(0)
	else:
		
		force_movement(0)
		damp_vertical_speed(_delta)
		character.set_vertical_speed( - vertical_speed)
		
	if invicible_frames():
		character.add_invulnerability("Genmuzero")
	else:
		character.remove_invulnerability("Genmuzero")

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	._Interrupt()
	character.execute_genmu_zero = false
	character.remove_invulnerability("Genmuzero")
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
