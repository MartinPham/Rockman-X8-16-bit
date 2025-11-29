extends FallZero
class_name SaberZeroX8Jump

onready var zbuster: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/zbuster.tscn")
onready var shingetsurin: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/shingetsurin.tscn")
onready var swordwave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/swordwave.tscn")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
var creator: Node2D
var last_direction: = 1

export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")
export  var damage: float = 4.0
export  var damage_boss: float = 4.0
export  var damage_weakness: float = 24.0
export  var hitbox_break_guards: bool = false

onready var animatedSprite: = character.get_node("animatedSprite")
onready var saber_sound: AudioStreamPlayer = $saber
onready var saber_sound2: AudioStreamPlayer = $saber2
onready var bfan_sound: AudioStreamPlayer = $bfan
onready var bfan2_sound: AudioStreamPlayer = $bfan2
onready var dglaive_sound: AudioStreamPlayer = $dglaive
onready var dglaive2_sound: AudioStreamPlayer = $dglaive2
onready var breaker_sound: AudioStreamPlayer = $breaker
onready var zbuster_sound: AudioStreamPlayer = $zbuster
onready var shingetsurin_sound: AudioStreamPlayer = $shingetsurin
onready var swordwave_sound: AudioStreamPlayer = $swordwave
onready var rogueslash_sound: AudioStreamPlayer = $rogueslash
onready var rogueslash2_sound: AudioStreamPlayer = $rogueslash2
onready var sigmablade_sound: AudioStreamPlayer = $sigmablade
onready var sigmablade2_sound: AudioStreamPlayer = $sigmablade2

var current_hitbox = null
var hitbox_upleft: Vector2 = Vector2(0, 0)
var hitbox_downright: Vector2 = Vector2(0, 0)
var hitbox_damage: float = 0
var hitbox_damage_boss: float = 0
var hitbox_damage_weakness: float = 0
var hitbox_break_guard_value: float = 0.4
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
var saber_sound_counter: int = 0
var slashing: bool = false
var slashes: int = 0
var landed: bool = false
var vertical_last: float = 0
var input_buffer: Array = []
var buffer_window_threshold: int = 2

var shot_time = 0

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
	hitbox_break_guard_value = 0.4

func set_hitbox_corners(upleft: Vector2, downright: Vector2) -> RectangleShape2D:
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	return shape

func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2) -> void :
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
	if character.saber_node.current_weapon.name == "Saber":
		hitbox_damage = damage
		hitbox_damage_boss = damage_boss
		hitbox_damage_weakness = damage_weakness
		hitbox_rehit_time = 0.25
		hitbox_break_guards = false
		if animatedSprite.animation == "saber_jump":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 9:
				hitbox_upleft = Vector2( - 29, - 51)
				hitbox_downright = Vector2(59, 50)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "saber_land":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2( - 5, - 40)
				hitbox_downright = Vector2(74, 16)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "saber_shot_fast2":
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

	elif character.saber_node.current_weapon.name == "B-Fan":
		hitbox_damage = damage
		hitbox_damage_boss = damage_boss
		hitbox_damage_weakness = damage_weakness
		hitbox_rehit_time = 0.25
		hitbox_break_guards = false
		if animatedSprite.animation == "saber_jump":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 15, - 42)
				hitbox_downright = Vector2(62, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(25, - 42)
				hitbox_downright = Vector2(62, 34)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 5 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2(5, - 42)
				hitbox_downright = Vector2(45, 60)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "saber_land":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 5, - 42)
				hitbox_downright = Vector2(72, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(35, - 42)
				hitbox_downright = Vector2(72, 34)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	elif character.saber_node.current_weapon.name == "D-Glaive":
		hitbox_damage = damage
		hitbox_damage_boss = damage_boss
		hitbox_damage_weakness = damage_weakness
		hitbox_rehit_time = 0.025
		hitbox_break_guards = false
		if animatedSprite.animation == "saber_jump":
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 62, - 105)
				hitbox_downright = Vector2( - 32, - 45)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 97, - 75)
				hitbox_downright = Vector2( - 62, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 32, - 123)
				hitbox_downright = Vector2(59, - 75)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(29, - 75)
				hitbox_downright = Vector2(59, - 45)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(59, - 75)
				hitbox_downright = Vector2(127, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 6 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2(19, 40)
				hitbox_downright = Vector2(89, 105)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "saber_land":
			if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
				hitbox_upleft = Vector2( - 100, - 60)
				hitbox_downright = Vector2( - 65, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 65, - 80)
				hitbox_downright = Vector2( - 35, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 2 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 35, - 103)
				hitbox_downright = Vector2(59, - 75)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2(29, - 75)
				hitbox_downright = Vector2(59, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(59, - 75)
				hitbox_downright = Vector2(127, 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)


	elif character.saber_node.current_weapon.name == "Rogue-Blade":
		hitbox_damage = damage
		hitbox_damage_boss = damage_boss
		hitbox_damage_weakness = damage_weakness
		hitbox_rehit_time = 0.25
		hitbox_break_guards = false
		if animatedSprite.animation == "saber_jump":
			if animatedSprite.frame >= 1 and animatedSprite.frame < 9:
				hitbox_upleft = Vector2( - 75, - 75)
				hitbox_downright = Vector2(0, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( 0, - 75)
				hitbox_downright = Vector2(75, 55)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "saber_land":
			if animatedSprite.frame >= 1 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2( - 45, - 42)
				hitbox_downright = Vector2(85, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	elif character.saber_node.current_weapon.name == "Sigma-Blade":
		hitbox_damage = damage
		hitbox_damage_boss = damage_boss
		hitbox_damage_weakness = damage_weakness
		hitbox_rehit_time = 0.025
		hitbox_break_guards = true
		if animatedSprite.animation == "saber_jump":
			if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 90, - 110)
				hitbox_downright = Vector2( 110, - 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(35, - 77)
				hitbox_downright = Vector2(115, - 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(30, - 30)
				hitbox_downright = Vector2(105, 70)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 6 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2(5, 0)
				hitbox_downright = Vector2(100, 95)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 7 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2(5, 0)
				hitbox_downright = Vector2(38, 95)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "saber_land":
			if animatedSprite.frame >= 1 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 105, - 60)
				hitbox_downright = Vector2( - 65, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 60, - 90)
				hitbox_downright = Vector2( 0, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 0, - 103)
				hitbox_downright = Vector2(115, - 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(55, - 80)
				hitbox_downright = Vector2(140, -10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(45, - 0)
				hitbox_downright = Vector2(120, -20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	if character.saber_node.current_weapon.name == "T-Breaker":
		hitbox_damage = damage
		hitbox_damage_boss = damage_boss
		hitbox_damage_weakness = damage_weakness
		hitbox_rehit_time = 0.25
		hitbox_break_guards = true
		if animatedSprite.animation == "saber_jump":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 13, - 76)
				hitbox_downright = Vector2(75, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(35, - 48)
				hitbox_downright = Vector2(75, 38)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2(10, 38)
				hitbox_downright = Vector2(75, 64)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "saber_land":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 5, - 68)
				hitbox_downright = Vector2(75, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(35, - 48)
				hitbox_downright = Vector2(90, 38)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	reset_hitbox()

func end_saber_state() -> bool:
	return ending_saber_state

func is_in_buffer_window() -> bool:
	if animatedSprite.animation == "saber_jump":
		if animatedSprite.frame >= 7 - buffer_window_threshold:
			return true
	return false

func should_add_saber_combo() -> bool:
	if character.saber_node.current_weapon.name == "T-Breaker":
		return false
	if animatedSprite.animation == "saber_jump":
		return animatedSprite.frame >= 7
	else:
		return false

func set_saber_animations() -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "saber_jump"
		animatedSprite.frame = 0
		if character.saber_node.current_weapon.name == "Saber":
			if CharacterManager.awakened_zero_armor and character.get_action_pressed("move_up"):
				create()
			elif CharacterManager.extra_saber_01 and CharacterManager.extra_saber_combo and character.get_action_pressed("select_special") and character.get_action_pressed("move_up") and not CharacterManager.awakened_zero_armor:
				if use_genmu.has_ammo_10():
					create()
					use_genmu.reduce_ammo(CharacterManager.buster_base_energy * 0.5)
			elif CharacterManager.extra_saber_01 and CharacterManager.extra_saber_combo and not character.get_action_pressed("select_special") and character.get_action_pressed("move_up"):
				animatedSprite.animation = "saber_shot_fast2"
				if saber_sound_counter == 0:
					saber_sound.play()
					saber_sound_counter += 1
				else:
					saber_sound2.play()
					saber_sound_counter = 0
			else:
				if saber_sound_counter == 0:
					saber_sound.play()
					saber_sound_counter += 1
				else:
					saber_sound2.play()
					saber_sound_counter = 0

		elif character.saber_node.current_weapon.name == "B-Fan":
			if saber_sound_counter == 0:
				bfan_sound.play()
				saber_sound_counter += 1
			else:
				bfan2_sound.play()
				saber_sound_counter = 0
		elif character.saber_node.current_weapon.name == "D-Glaive":
			if saber_sound_counter == 0:
				dglaive_sound.play()
				saber_sound_counter += 1
			else:
				dglaive2_sound.play()
				saber_sound_counter = 0
		elif character.saber_node.current_weapon.name == "T-Breaker":
			breaker_sound.play()
		elif character.saber_node.current_weapon.name == "Z-Breaker":
			if CharacterManager.awakened_zero_armor:
				shingetsurin_sound.play()
				create_shingetsurin(global_position, 10)
			elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
				zbuster_sound.play()
				create_zbuster(global_position, 3.6)
			else:
				zbuster_sound.play()
				create_zbuster(global_position, 3)
		elif character.saber_node.current_weapon.name == "Rogue-Blade":
			if saber_sound_counter == 0:
				rogueslash_sound.play()
				saber_sound_counter += 1
			else:
				rogueslash2_sound.play()
				saber_sound_counter = 0
		elif character.saber_node.current_weapon.name == "Sigma-Blade":
			if saber_sound_counter == 0:
				sigmablade_sound.play()
				saber_sound_counter += 1
			else:
				sigmablade2_sound.play()
				saber_sound_counter = 0
		else:
			if saber_sound_counter == 0:
				saber_sound.play()
				saber_sound_counter += 1
			else:
				saber_sound2.play()
				saber_sound_counter = 0

func create() -> void :
	last_direction = character.get_facing_direction()
	animatedSprite.animation = "saber_shot_fast2"
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

func create_zbuster(ground_position,  damage_value) -> void :
	var instance = zbuster.instance()
	ground_position.y += -15
	instance.damage =  damage_value * 2
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_shingetsurin(ground_position,  damage_value) -> void :
	var instance = shingetsurin.instance()
	ground_position.y += -15
	instance.damage =  damage_value * 2
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

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
	if CharacterManager.extra_saber_combo and CharacterManager.extra_saber_04 and character.saber_node.current_weapon.name == "Saber":
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
		if _animation == "genmuzero":
			return false
		if _animation == "genmuzeroair":
			return false
		if _animation == "ryuenjin":
			return false
		if "hyouryuushou" in _animation:
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
	shot_time = 0
	if CharacterManager.player_character == "Zero" and CharacterManager.awakened_zero_armor:
		dashjump_speed = 400
	else:
		dashjump_speed = 300

	landed = false
	if vertical_last != 0:
		character.velocity.y = vertical_last
	set_saber_animations()
	if character.dashjumps_since_jump > 0:
		horizontal_velocity = dashjump_speed
		character.dashjump_signal()
	else:
		horizontal_velocity = 90
	ending_saber_state = false

func _Update(_delta: float) -> void :
	hitbox_and_position()
	
	if is_in_buffer_window() and character.get_action_just_pressed(actions[0]):
		input_buffer.append(actions[0])
	
	if should_add_saber_combo() and input_buffer.size() > 0:
		input_buffer.pop_front()
		set_saber_animations()

	if not character.is_executing("WallJump") and not character.is_executing("DashWallJump"):
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
	
	if animatedSprite.animation == "saber_shot_fast2":
		set_horizontal_speed(0)
		set_vertical_speed(0)

func change_animation_if_falling(_s) -> void :
	animatedSprite.animation = "fall"

func _Interrupt() -> void :
	slashes = 0
	input_buffer = []
	var _fall_node = character.get_node("Fall")
	_fall_node.horizontal_velocity = horizontal_velocity
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
