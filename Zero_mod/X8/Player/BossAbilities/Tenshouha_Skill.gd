extends Movement
class_name SaberTenshouhaX8

onready var animatedSprite = character.get_node("animatedSprite")
onready var laser = preload("res://src/Actors/Player/BossWeapons/OpticShield/OpticShieldCharged.tscn")
onready var arrow: PackedScene = preload("res://Zero_mod/X8/Sprites/vhanger/object/HangerArrow.tscn")
onready var rogueslash: PackedScene = preload("res://Zero_mod/X8/Sprites/rogueblade/object/rogueslash.tscn")
onready var rekohouha: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/RekohouhaX6.tscn")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
onready var ground_check: RayCast2D = $ground_check
onready var laser_cast_frame: int = 5
onready var sfx: Node = $sfx
var shot_time = 0
var last_position: Vector2

onready var hangerarrow_sound: AudioStreamPlayer = $HangerArrow
onready var roguewave_sound: AudioStreamPlayer = $RogueWave
onready var rekohouha_sound: AudioStreamPlayer2D = $boom
onready var rekohouha2_sound: AudioStreamPlayer2D = $boom2
var ending_saber_state: bool = false
var creator: Node2D
var laser_casted: bool = false

func _ready() -> void :
	Event.connect("saber_has_hit_boss", self, "reduce_speed")
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")
	
func _on_animation_finished() -> void :
	character.remove_invulnerability("Tenshouha")
	ending_saber_state = true

func end_ability_state() -> bool:
	return ending_saber_state

func cast_laser() -> void :
	if not laser_casted:
		if animatedSprite.animation == "tenshouha":
			if animatedSprite.frame >= laser_cast_frame:
				fire_laser()
				laser_casted = true

func _StartCondition() -> bool:
	if not character.Tenshouha:
		return false
	if not use_genmu.has_ammo_30() and character.saber_node.current_weapon.name == "Z-Breaker":
		if not CharacterManager.awakened_zero_armor:
			return false
	if not character.get_action_pressed("move_down"):
		return false
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	if not executing:
		if character.is_on_floor():
			return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if not _animation == "tenshouha":
			return true
		if end_ability_state():
			return true
	else:
		return true
	return false

func _Setup() -> void :
	shot_time = 0
	update_bonus_horizontal_only_conveyor()
	changed_animation = false
	laser_casted = false
	ending_saber_state = false

func _Update(_delta: float) -> void :
	cast_laser()
	force_movement(0)
	
	process_gravity(_delta)
	update_bonus_horizontal_only_conveyor()

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	._Interrupt()

func fire_laser() -> void :
	character.add_invulnerability("Tenshouha")
	animatedSprite.material.set_shader_param("Alpha", 1)
	last_position = character.global_position
	var ground_position = Vector2(global_position.x, global_position.y + 256)
	if character.saber_node.current_weapon.name == "Saber" or \
	character.saber_node.current_weapon.name == "B-Fan" or \
	character.saber_node.current_weapon.name == "D-Glaive" or \
	character.saber_node.current_weapon.name == "T-Breaker" or \
	character.saber_node.current_weapon.name == "K-Knuckle":
		if ground_check.is_colliding():
			ground_position = ground_check.get_collision_point()
			create_laser(ground_position)
			if CharacterManager.awakened_zero_armor:
				create_laser(ground_position + Vector2( + 40, 0))
				create_laser(ground_position + Vector2( - 40, 0))
	if character.saber_node.current_weapon.name == "V-Hanger":
			hangerarrow_sound.play()
			if CharacterManager.awakened_zero_armor:
				create_arrow(global_position, 10)
			elif CharacterManager.black_zero_armor:
				create_arrow(global_position, 6)
			else:
				create_arrow(global_position, 5)
	if character.saber_node.current_weapon.name == "Rogue-Blade":
			roguewave_sound.play()
			if CharacterManager.awakened_zero_armor:
				create_rogueslash(global_position, 20)
			elif CharacterManager.black_zero_armor:
				create_rogueslash(global_position, 12)
			else:
				create_rogueslash(global_position, 10)
	if character.saber_node.current_weapon.name == "Sigma-Blade":
		if ground_check.is_colliding():
			ground_position = ground_check.get_collision_point()
			if CharacterManager.awakened_zero_armor:
				create_lasershort(ground_position)
				shot_time += 1
				Tools.timer(0.1, "summon_lasershort", self)
				Tools.timer(0.2, "summon_lasershort", self)
				Tools.timer(0.3, "summon_lasershort", self)
				Tools.timer(0.4, "summon_lasershort", self)
				Tools.timer(0.5, "summon_lasershort", self)
				Tools.timer(0.6, "summon_lasershort", self)
				Tools.timer(0.7, "summon_lasershort", self)
			else:
				create_laser(ground_position)
				create_laser(ground_position + Vector2( + 40, 0))
				create_laser(ground_position + Vector2( - 40, 0))

	if character.saber_node.current_weapon.name == "Z-Breaker":
		if ground_check.is_colliding():
			ground_position = ground_check.get_collision_point()
			rekohouha_sound.play()
			rekohouha2_sound.play()
			create_rekohouha(last_position)
			shot_time += 1
			Tools.timer(0.2, "summon_rekohouha", self)
			Tools.timer(0.4, "summon_rekohouha", self)
			Tools.timer(0.6, "summon_rekohouha", self)
			Tools.timer(0.8, "summon_rekohouha", self)
			Tools.timer(1.0, "summon_rekohouha", self)
			Tools.timer(1.2, "summon_rekohouha", self)
			if not CharacterManager.awakened_zero_armor:
				use_genmu.reduce_ammo(CharacterManager.buster_base_energy * 1.5)

func summon_rekohouha() -> void :
	if shot_time == 1 or shot_time == 3 or shot_time == 5 or shot_time == 7:
		create_rekohouhadown(last_position + Vector2( shot_time * 30, 0))
		create_rekohouhadown(last_position + Vector2( shot_time * - 30, 0))
	else:
		create_rekohouha(last_position + Vector2( shot_time * 30, 0))
		create_rekohouha(last_position + Vector2( shot_time * - 30, 0))
	rekohouha2_sound.play()
	shot_time += 1

func summon_lasershort() -> void :
	var ground_position = Vector2(last_position.x, last_position.y + 256)
	if ground_check.is_colliding():
		ground_position = ground_check.get_collision_point()
		create_lasershort(ground_position + Vector2( shot_time * 40, 0))
		create_lasershort(ground_position + Vector2( shot_time * - 40, 0))
	shot_time += 1

func invicible_frames() -> bool:
	return animatedSprite.frame >= 6 and animatedSprite.frame < 12

func deflect_projectile(body):
	if body.is_in_group("Enemy Projectile"):
		if body.has_method("_OnHit"):
			body._OnHit(self)
			return
		body.destroy()

func create_laser(ground_position) -> void :
	var instance = laser.instance()
	ground_position.y += 7
	instance.modulate = Color(1, 1, 1, 0.65)
	instance.z_index = character.z_index + 10
	instance.mid_animation_time = 0.12
	instance.end_animation_time = 1.45
	instance.deflectable = true
	instance.damage = 2
	instance.damage_to_bosses = 1
	instance.damage_to_weakness = 25
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.5)

func create_lasershort(ground_position) -> void :
	var instance = laser.instance()
	ground_position.y += 7
	instance.modulate = Color(1, 1, 1, 0.65)
	instance.z_index = character.z_index + 10
	instance.mid_animation_time = 0.12
	instance.end_animation_time = 0.36
	instance.deflectable = true
	instance.damage = 4
	instance.damage_to_bosses = 2
	instance.damage_to_weakness = 30
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.5)

func create_arrow(global_position, damage_value) -> void :
	var instance = arrow.instance()
	instance.damage = damage_value * 2
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(global_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_rogueslash(global_position, damage_value) -> void :
	var instance = rogueslash.instance()
	instance.damage = damage_value
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(global_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_rekohouha(ground_position) -> void :
	var instance = rekohouha.instance()
	ground_position.y += 10
	instance.damage = 40
	instance.damage_to_bosses = 40
	instance.damage_to_weakness = 40
	instance.speed = 1200
	instance.scale.y = 1
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.3)

func create_rekohouhadown(ground_position) -> void :
	var instance = rekohouha.instance()
	ground_position.y += 10
	instance.damage = 40
	instance.damage_to_bosses = 40
	instance.damage_to_weakness = 40
	instance.speed = - 1200
	instance.scale.y = - 1
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.3)


