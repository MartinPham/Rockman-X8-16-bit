extends SaberBaseZeroX8
class_name SaberZeroX8Dash

onready var swordwave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/swordwave.tscn")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
var creator: Node2D

onready var bfan_sound: AudioStreamPlayer = $bfan
onready var dglaive_sound: AudioStreamPlayer = $dglaive
onready var breaker_sound: AudioStreamPlayer = $breaker
onready var swordwave_sound: AudioStreamPlayer = $swordwave
onready var rogueslash_sound: AudioStreamPlayer = $rogueslash
onready var sigmablade_sound: AudioStreamPlayer = $sigmablade

var horizontal_speed: float = horizontal_velocity
var damping: float = 0.97


func hitbox_and_position() -> void :
	if animatedSprite.animation == "saber_dash2":
		hitbox_damage = damage * 0.75
		hitbox_damage_boss = damage_boss * 0.75
		hitbox_damage_weakness = damage_weakness
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_break_guards = true
			hitbox_rehit_time = 0.0125
			if animatedSprite.frame >= 3 and animatedSprite.frame < 9:
				hitbox_upleft = Vector2( - 17, - 15)
				hitbox_downright = Vector2(95, 15)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_dash":
		hitbox_damage = damage * 1.5
		hitbox_damage_boss = damage_boss * 1.5
		hitbox_damage_weakness = damage_weakness
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_break_guards = true
			hitbox_rehit_time = 0.025
			if animatedSprite.frame >= 4 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2( - 17, - 52)
				hitbox_downright = Vector2(67, 15)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "B-Fan":
			hitbox_break_guards = true
			hitbox_rehit_time = 0.025
			if animatedSprite.frame >= 4 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2( - 17, - 52)
				hitbox_downright = Vector2(67, 35)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "D-Glaive":
			hitbox_break_guards = true
			hitbox_rehit_time = 0.0125
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 62, - 75)
				hitbox_downright = Vector2( - 32, - 45)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 97, - 75)
				hitbox_downright = Vector2( - 62, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 32, - 123)
				hitbox_downright = Vector2(59, - 75)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(29, - 75)
				hitbox_downright = Vector2(59, - 45)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(59, - 75)
				hitbox_downright = Vector2(127, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "T-Breaker":
			hitbox_rehit_time = 0.025
			hitbox_break_guards = true
			if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2( - 5, - 68)
				hitbox_downright = Vector2(75, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2(35, - 48)
				hitbox_downright = Vector2(85, 38)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Z-Breaker":
			hitbox_rehit_time = 0.2
			hitbox_break_guards = true
			if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2( - 25, - 34)
				hitbox_downright = Vector2(18, - 15)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2( - 5, - 39)
				hitbox_downright = Vector2(68, 21)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Rogue-Blade":
			hitbox_break_guards = true
			hitbox_rehit_time = 0.025
			if animatedSprite.frame >= 1 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2( - 45, - 42)
				hitbox_downright = Vector2(85, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Sigma-Blade":
			hitbox_break_guards = true
			hitbox_rehit_time = 0.0125
			if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 105, - 60)
				hitbox_downright = Vector2( - 65, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 60, - 90)
				hitbox_downright = Vector2( 0, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2( - 0, - 103)
				hitbox_downright = Vector2(115, - 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(55, - 80)
				hitbox_downright = Vector2(140, 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 6 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2(45, - 0)
				hitbox_downright = Vector2(120, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)



	reset_hitbox()

func end_saber_state() -> bool:
	return ending_saber_state

func should_add_saber_combo() -> bool:
	return false

func set_saber_animations() -> void :
	animatedSprite.animation = "saber_dash"
	if character.saber_node.current_weapon.name == "Saber":
		saber_sound.play()
		if CharacterManager.extra_saber_02 and CharacterManager.extra_saber_combo and character.get_action_pressed("move_down"):
			animatedSprite.animation = "saber_dash2"
	elif character.saber_node.current_weapon.name == "B-Fan":
		bfan_sound.play()
	elif character.saber_node.current_weapon.name == "D-Glaive":
		dglaive_sound.play()
	elif character.saber_node.current_weapon.name == "T-Breaker":
		breaker_sound.play()
	elif character.saber_node.current_weapon.name == "Z-Breaker":
		swordwave_sound.play()
		if CharacterManager.awakened_zero_armor:
			create_swordwave(global_position, 20)
		if CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
			create_swordwave(global_position, 12)
		else:
			create_swordwave(global_position, 10)
	elif character.saber_node.current_weapon.name == "Rogue-Blade":
		rogueslash_sound.play()
	elif character.saber_node.current_weapon.name == "Sigma-Blade":
		sigmablade_sound.play()
	else:
		saber_sound.play()

func create_swordwave(ground_position,  damage_value) -> void :
	var instance = swordwave.instance()
	ground_position.y += -9
	instance.damage =  damage_value * 2
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	if CharacterManager.extra_saber_03 and CharacterManager.extra_saber_combo and character.get_action_pressed("move_up") and character.saber_node.current_weapon.name == "Saber":
		return false
	if not executing:
		if _animation == "dash":
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
	horizontal_speed = horizontal_velocity
	update_bonus_horizontal_only_conveyor()
	slashing = false
	set_saber_animations()
	ending_saber_state = false

func damp_horizontal_speed(_delta: float) -> void :
	var reference_delta = 1.0 / 120
	var damping_factor = pow(damping, _delta / reference_delta)
	horizontal_speed *= damping_factor

func _Update(_delta: float) -> void :
	hitbox_and_position()
	force_movement(horizontal_speed)
	damp_horizontal_speed(_delta)
	
	update_bonus_horizontal_only_conveyor()
	if animatedSprite.animation == "saber_dash2":
		force_movement(horizontal_velocity)

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	
	character.dashjumps_since_jump = 0
	character.dashfall = false
	slashes = 0
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
