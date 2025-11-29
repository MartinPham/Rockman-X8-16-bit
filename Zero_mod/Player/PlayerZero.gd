extends Character

export  var skip_intro: = false

onready var duringimage = $Dash/duringImage
onready var airduringimage = $AirDash/duringImage

onready var swordwave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/swordwave.tscn")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
var creator: Node2D

var current_armor = ["no_head", "no_body", "no_arms", "no_legs"]
var armor_sprites = []
var flash_timer: = 0.0
var block_charging: = false
var dashfall: = false
var dashed: bool = false
var dashjumps_since_jump: = 0
var raycast_down: RayCast2D
var colliding: = true
var using_upgrades: = false
var grabbed: = false
var ride_eject_delay: float = 0.0
onready var lowjumpcast: Label = $lowjumpcast

onready var saber_node = get_node("Shot")
onready var _saber_sprites = preload("res://Zero_mod/Sprites/zero.tres")
onready var awakenaura_shield: = get_node("awakenaura")
onready var rekkyoudan_hitbox = preload("res://Zero_mod/Player/Hitboxes/Rekkyoudan_Hitbox.tscn")
onready var saber_hitbox = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")

onready var saber_combo: = get_node("SaberCombo")
onready var saber_dash: = get_node("SaberDash")
onready var saber_jump: = get_node("SaberJump")
onready var saber_wall: = get_node("SaberWall")

onready var skill_tenshouha: = get_node("Tenshouha")
onready var skill_juuhazan: = get_node("Juuhazan")
onready var skill_rasetsusen: = get_node("Rasetsusen")
onready var skill_raikousen: = get_node("Raikousen")
onready var skill_youdantotsu: = get_node("Youdantotsu")
onready var skill_hyouryuushou: = get_node("Hyouryuushou")
onready var skill_enkoujin: = get_node("Enkoujin")

var Tenshouha: bool = false
var Juuhazan: bool = false
var Rasetsusen: bool = false
var Rasetsusen_used: bool = false
var Raikousen: bool = false
var Youdantotsu: bool = false
var Rekkyoudan: bool = false
var Hyouryuushou: bool = false
var Hyouryuushou_used: bool = false
var Enkoujin: bool = false
var Enkoukyaku: bool = false

var execute_genmu_zero: bool = false

var saber_animations = [
	"ryuenjin",
	"saber_shot",
	"saber_shot_normal",
	"saber_shot_normal2",
	"saber_1", 
	"saber_2", 
	"saber_3", 
	"saber_dash", 
	"saber_dash2", 
	"saber_jump", 
	"saber_land", 
	"saber_slide", 
	"juuhazan", 
	"rasetsusen", 
	"tenshouha", 
	"youdantotsu", 
	"youdantotsua", 
	"youdantotsuawaken", 
	"youdantotsuawakena", 
	"hyouryuushou", 
	"enkoujin", 
	"raikousen", 
	"genmuzero", 
	"genmuzeroair", 
	"rekuhouha", 
	"saber_rasetsusen", 
	"saber_shot_fast1", 
]

signal walljump
signal wallslide
signal dashjump
signal airdash
signal firedash
signal collected_health(amount)
signal weapon_stasis
signal end_weapon_stasis
signal dry_dash
signal received_damage(character)
signal equipped_armor
signal at_max_hp

var ride: Node2D

func deactivate():
	stop_listening_to_inputs()
	stop_charge()
	stop_shot()
	Log("not active")
	
func activate():
	if is_colliding():
		reactivate_charge()
		.activate()
	
	return

func has_control() -> bool:
	if grabbed:
		return true
	if listening_to_inputs:
		return true
	elif ride:
		return ride.listening_to_inputs
	return false

func is_riding() -> bool:
	return is_instance_valid(ride)

func on_land() -> void :
	dashjumps_since_jump = 0
	dashfall = false
	Rasetsusen_used = false
	Hyouryuushou_used = false

func dashjump_signal() -> void :
	emit_signal("dashjump")
	dashjumps_since_jump += 1
	
func airdash_signal() -> void :
	emit_signal("airdash")
	
func firedash_signal() -> void :
	emit_signal("firedash")

func stop_charge():
	for ability in executing_moves:
		if ability.name == "Charge":
			ability.EndAbility()
	block_charging = true
	
func update_facing_direction():
	if direction.x < 0:
		facing_right = false;
		Event.emit_signal("player_faced_left")
	elif direction.x > 0:
		facing_right = true;
		Event.emit_signal("player_faced_right")
	if animatedSprite.scale.x != get_facing_direction():
		animatedSprite.scale.x = get_facing_direction()

func reactivate_charge():
	block_charging = false

func reduce_hitbox():
	collisor.disabled = true

func increase_hitbox():
	collisor.disabled = false
	

func _ready() -> void :
	current_armor = ["no_head", "no_body", "no_arms", "no_legs"]
	Event.listen("collected", self, "equip_parts")
	Event.listen("collected", self, "collect")
	listen("land", self, "on_land")
	equip_zero_parts()
	save_original_colors()
	CharacterManager.weaponget = false
	if is_current_player:
		GameManager.set_player(self)
		Event.call_deferred("emit_signal", "player_set")
	animatedSprite.offset.y = - 2
	change_ride_chaser_sprites()

func change_ride_chaser_sprites():
	var _texture = load("res://Zero_mod/Sprites/zero_ride_chaser.png")
	var _reference_frames = load("res://Zero_mod/Sprites/zero.tres")
	var _replace_animations = [
		"boost", 
	]
	animatedSprite.frames = CharacterManager.update_texture_specific_animations(_texture, _reference_frames, _replace_animations)

func get_armor_sprites() -> Array:
	var sprites = []
	for child in animatedSprite.get_children():
		if "armor" in child.name:
			sprites.append(child)
	return sprites

func _process(delta: float) -> void :
	if skill_rasetsusen.saber_sound.playing and animatedSprite.animation != "rasetsusen":
		skill_rasetsusen.saber_sound.stop()
	if ride_eject_delay >= 0:
		ride_eject_delay -= delta
	process_flash(delta)

func spike_touch():
	if not spike_invincibility:
		if should_instantly_die() and not is_invulnerable():
			Log("Death by Spikes")
			CharacterManager.both_alive = false
			emit_signal("zero_health")

func lava_touch():
	if not spike_invincibility:
		if should_instantly_die():
			Log("Death by Lava")
			CharacterManager.both_alive = false
			emit_signal("zero_health")

func void_touch():
	Log("Death by falling")
	CharacterManager.both_alive = false
	emit_signal("zero_health")


func should_instantly_die() -> bool:
	return not is_executing("Ride")

func process_flash(delta):
	if flash_timer > 0:
		flash_timer += delta
		if flash_timer > 0.034:
			end_flash()
	
func equip_zero_parts():
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	var saberdash = get_node("SaberDash")
	var airjump = get_node("AirJump")
	var fall = get_node("Fall")
	dash.invulnerability_duration = 0
	airdash.upgraded = false
	airdash.max_airdashes = 1
	airjump.set_max_air_jumps(1)
	airjump.upgraded = false
	fall.upgraded = false
	


	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 0.5
	lifesteal.lifesteal_decay = 0.5
	lifesteal.minimum_time_between_heals = 0.2


	
	var dmg = get_node("Damage")
	dmg.damage_reduction = 50
	dmg.prevent_knockbacks = false
	dmg.conflicting_moves = ["Death", "WallSlide", "Ride"]
	



	
	
	dash.horizontal_velocity = 300
	airdash.horizontal_velocity = 300
	saberdash.horizontal_velocity = 300
	fall.dashjump_speed = 300
	var _afterimage = animatedSprite.get_node("afterImages")
	_afterimage.upgraded = false
	
	
	var dmg_multiplikator = 1.0
	var saber_nodes = [
		get_node("SaberCombo"), 
		get_node("SaberDash"), 
		get_node("SaberJump"), 
		get_node("SaberWall"), 
		get_node("Juuhazan"), 
		get_node("Rasetsusen"), 
		get_node("Raikousen"), 
		get_node("Youdantotsu"), 
		get_node("Hyouryuushou"), 
		get_node("Enkoujin")
	]
	for _saber_node in saber_nodes:
		_saber_node.hitbox_extra_damage = dmg_multiplikator
		_saber_node.hitbox_extra_damage_boss = dmg_multiplikator
		_saber_node.hitbox_extra_damage_weakness = dmg_multiplikator
		_saber_node.hitbox_extra_break_guard_value = dmg_multiplikator

	get_node("Youdantotsu").hitbox_upgraded = true
	for _saber_node in saber_nodes:
		if _saber_node != get_node("Youdantotsu"):
			_saber_node.hitbox_upgraded = false
	get_node("Rasetsusen").upgraded = false
	get_node("Rasetsusen").cast_time_max = 0.5
	awakenaura_shield.hitbox_upgraded = true


func equip_black_zero_parts():
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	var saberdash = get_node("SaberDash")
	var airjump = get_node("AirJump")
	var fall = get_node("Fall")
	dash.invulnerability_duration = 0
	airdash.max_airdashes = 2
	airjump.set_max_air_jumps(2)
	airjump.upgraded = true
	fall.upgraded = true
	
	dash.upgraded = true
	airdash.upgraded = true
	dash.invulnerability_duration = 1.0
	airdash.invulnerability_duration = 1.0

	dash.get_node("particles2D").texture = load("res://Zero_mod/Effects/follow_shot_hide.png")
	airdash.get_node("particles2D").texture = load("res://Zero_mod/Effects/follow_shot_hide.png")
	duringimage.modulate = Color(0, 0, 0, 1)
	airduringimage.modulate = Color(0, 0, 0, 1)
	
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 1.5
	lifesteal.lifesteal_decay = 0.65
	lifesteal.minimum_time_between_heals = 0.1
	
	var dmg = get_node("Damage")
	dmg.damage_reduction = 0
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]
	
	
	dash.horizontal_velocity = 300
	airdash.horizontal_velocity = 300
	saberdash.horizontal_velocity = 300
	fall.dashjump_speed = 300
	var _afterimage = animatedSprite.get_node("afterImages")
	_afterimage.upgraded = true
	
	
	var dmg_multiplikator = 1.5
	var saber_nodes = [
		get_node("SaberCombo"), 
		get_node("SaberDash"), 
		get_node("SaberJump"), 
		get_node("SaberWall"), 
		get_node("Juuhazan"), 
		get_node("Rasetsusen"), 
		get_node("Raikousen"), 
		get_node("Youdantotsu"), 
		get_node("Hyouryuushou"), 
		get_node("Enkoujin")
	]
	for _saber_node in saber_nodes:
		_saber_node.hitbox_upgraded = true
		_saber_node.hitbox_extra_damage = dmg_multiplikator
		_saber_node.hitbox_extra_damage_boss = dmg_multiplikator
		_saber_node.hitbox_extra_damage_weakness = dmg_multiplikator
		_saber_node.hitbox_extra_break_guard_value = dmg_multiplikator

	get_node("Youdantotsu").hitbox_upgraded = true
	for _saber_node in saber_nodes:
		if _saber_node != get_node("Youdantotsu"):
			_saber_node.hitbox_upgraded = true
	get_node("Rasetsusen").upgraded = true
	get_node("Rasetsusen").cast_time_max = 0.5
	awakenaura_shield.hitbox_upgraded = true

func equip_awakened_zero_parts() -> void :
	spike_invincibility = true
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	var airjump = get_node("AirJump")
	var fall = get_node("Fall")
	airdash.max_airdashes = 4
	airdash.airdash_count = 4
	airjump.set_max_air_jumps(3)
	airjump.upgraded = true
	fall.upgraded = true

	dash.upgraded = true
	airdash.upgraded = true
	dash.invulnerability_duration = 1.0
	airdash.invulnerability_duration = 1.0

	dash.get_node("particles2D").texture = load("res://Zero_mod/Effects/follow_shot_hide.png")
	airdash.get_node("particles2D").texture = load("res://Zero_mod/Effects/follow_shot_hide.png")

	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 5.0
	lifesteal.lifesteal_decay = 2.5
	lifesteal.minimum_time_between_heals = 0.1
	
	var dmg = get_node("Damage")
	dmg.damage_reduction = 80
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]
	
	
	get_node("Jump").max_jump_time = 0.75
	get_node("Jump").jump_velocity = 420
	get_node("DashJump").max_jump_time = 0.75
	get_node("DashJump").jump_velocity = 420
	get_node("WallJump").max_jump_time = 0.75
	get_node("WallJump").jump_velocity = 420
	get_node("DashWallJump").max_jump_time = 0.75
	get_node("DashWallJump").jump_velocity = 420
	airjump.max_jump_time = 0.75
	airjump.jump_velocity = 230
	
	
	dash.horizontal_velocity = 400
	airdash.horizontal_velocity = 400
	saber_dash.horizontal_velocity = 400
	saber_jump.horizontal_velocity = 400
	get_node("SaberJump").horizontal_velocity = 400
	get_node("DashJump").horizontal_velocity = 400
	get_node("DashWallJump").horizontal_velocity = 400
	airjump.dashjump_speed = 400
	fall.dashjump_speed = 400
	var _afterimage = animatedSprite.get_node("afterImages")
	_afterimage.upgraded = true
	
	
	if CharacterManager.NO_MOVEMENT_CHALLENGE:
		get_node("Walk").horizontal_velocity = 0.0
		get_node("Jump").horizontal_velocity = 0.0
		get_node("DashJump").horizontal_velocity = 0.0
		get_node("WallJump").horizontal_velocity = 0.0
		get_node("DashWallJump").horizontal_velocity = 0.0
		airjump.horizontal_velocity = 0.0
		airjump.dashjump_speed = 0.0
		airjump.fall_base_velocity = 0.0
		dash.horizontal_velocity = 0.0
		airdash.horizontal_velocity = 0.0
		fall.horizontal_velocity = 0.0
		fall.dashjump_speed = 0.0
		fall.fall_base_velocity = 0.0
	
	
	var dmg_multiplikator = 1.5
	var saber_nodes = [
		get_node("SaberCombo"), 
		get_node("SaberDash"), 
		get_node("SaberJump"), 
		get_node("SaberWall"), 
		get_node("Juuhazan"), 
		get_node("Rasetsusen"), 
		get_node("Raikousen"), 
		get_node("Youdantotsu"), 
		get_node("Hyouryuushou"), 
		get_node("Enkoujin")
	]
	for _saber_node in saber_nodes:
		_saber_node.hitbox_upgraded = true
		_saber_node.hitbox_extra_damage = dmg_multiplikator
		_saber_node.hitbox_extra_damage_boss = dmg_multiplikator
		_saber_node.hitbox_extra_damage_weakness = dmg_multiplikator
		_saber_node.hitbox_extra_break_guard_value = dmg_multiplikator
		
	get_node("Youdantotsu").hitbox_upgraded = true
	for _saber_node in saber_nodes:
		if _saber_node != get_node("Youdantotsu"):
			_saber_node.hitbox_upgraded = true
	get_node("Rasetsusen").upgraded = true
	get_node("Rasetsusen").cast_time_max = 0.5
	awakenaura_shield.hitbox_upgraded = true

func equip_custom_zero_parts() -> void :
	var _afterimage = animatedSprite.get_node("afterImages")
	_afterimage.upgraded = true

func equip_awakened_zero_up_parts() -> void :
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 10.0
	lifesteal.lifesteal_decay = 5.0
	lifesteal.minimum_time_between_heals = 0.1
	
	var dmg = get_node("Damage")
	dmg.damage_reduction = 99
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]
	var _afterimage = animatedSprite.get_node("afterImages")
	_afterimage.upgraded = true
	
	var dmg_multiplikator = 2.0
	var saber_nodes = [
		get_node("SaberCombo"), 
		get_node("SaberDash"), 
		get_node("SaberJump"), 
		get_node("SaberWall"), 
		get_node("Juuhazan"), 
		get_node("Rasetsusen"), 
		get_node("Raikousen"), 
		get_node("Youdantotsu"), 
		get_node("Hyouryuushou"), 
		get_node("Enkoujin")
	]
	for _saber_node in saber_nodes:
		_saber_node.hitbox_upgraded = true
		_saber_node.hitbox_extra_damage = dmg_multiplikator
		_saber_node.hitbox_extra_damage_boss = dmg_multiplikator
		_saber_node.hitbox_extra_damage_weakness = dmg_multiplikator
		_saber_node.hitbox_extra_break_guard_value = dmg_multiplikator
		
	get_node("Youdantotsu").hitbox_upgraded = true
	for _saber_node in saber_nodes:
		if _saber_node != get_node("Youdantotsu"):
			_saber_node.hitbox_upgraded = true
	get_node("Rasetsusen").upgraded = true
	get_node("Rasetsusen").cast_time_max = 0.5
	awakenaura_shield.hitbox_upgraded = true

func is_full_armor() -> String:
	return "zero"

func equip_parts(collectible: String):
	CharacterManager.set_zero_colors(animatedSprite)
	equip_zero_parts()
	emit_signal("equipped_armor")
	
	if CharacterManager.black_zero_armor:
		equip_black_zero_parts()
		using_upgrades = true
		
	if CharacterManager.custom_zero_armor:
		equip_custom_zero_parts()
		
	if CharacterManager.awakened_zero_armor:
		equip_awakened_zero_parts()
		
	if CharacterManager.awakened_zero_full_power_max and CharacterManager.awakened_zero_armor:
		equip_awakened_zero_up_parts()
		using_upgrades = true
		
	if is_heart(collectible):
		equip_heart()
		using_upgrades = true
		
	elif is_subtank(collectible):
		equip_subtank(collectible)
		using_upgrades = true
		
	elif is_weapon(collectible):
		equip_weapon(collectible)

func is_weapon(collectible: String) -> bool:
	return "weapon" in collectible

func equip_weapon(collectible: String) -> void :
	get_node("Shot").unlock_ability(collectible)
	get_node("Shot").unlock_weapon(collectible)
	
func get_current_weapon():
	return get_node("Shot").current_weapon

func is_heart(collectible: String) -> bool:
	return "heart" in collectible or "life" in collectible

func is_subtank(collectible: String) -> bool:
	return "tank" in collectible

func equip_heart():
	var i = GameManager.team.find(self)
	if i == -1:
		return
	var buff = CharacterManager.heart_tank_buff_amt
	GameManager.team[i].max_health += buff
	GameManager.team[i].recover_health(buff)
	num_equipped_hearts += 1

func recover_health(value: float):
	if current_health < max_health:
		current_health += value
	if current_health >= max_health:
		emit_signal("at_max_hp")

func equip_subtank(collectible: String):
	for subtank in $Subtanks.get_children():
		if subtank.subtank.id == collectible:
			subtank.activate()

func get_subtank_current_health(id) -> int:
	for subtank in $Subtanks.get_children():
		if subtank.get_id() == id:
			return subtank.current_health
	return - 1
	
func add_part_to_current_armor(collectible: String):
	var part_location = collectible.replace("icarus_", "").replace("hermes_", "")
	for location in current_armor:
		if part_location in location:
			current_armor.remove(current_armor.find(location))
			current_armor.append(collectible)
	GameManager.remove_equip_exception(part_location)

func is_armor_part(collectible: String) -> bool:
	return "icarus" in collectible or "hermes" in collectible

func finished_equipping() -> void :
	get_node("Shot").update_list_of_weapons()

func has_any_upgrades() -> bool:
	return true

func collect(collectible: String):
	GameManager.add_collectible_to_savedata(collectible)

func save_original_colors():
	colors.append(animatedSprite.material.get_shader_param("MainColor1"))
	colors.append(animatedSprite.material.get_shader_param("MainColor2"))
	colors.append(animatedSprite.material.get_shader_param("MainColor3"))
	colors.append(animatedSprite.material.get_shader_param("MainColor4"))
	colors.append(animatedSprite.material.get_shader_param("MainColor5"))
	colors.append(animatedSprite.material.get_shader_param("MainColor6"))

func change_palette(new_colors, paint_armor: = true):
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	set_new_colors_on_shader_parameters(animatedSprite, new_colors)
	if paint_armor:
		for sprite in armor_sprites:
			set_new_colors_for_armor_on_shader_parameters(sprite, new_colors)
	else:
		for sprite in armor_sprites:
			set_new_colors_for_armor_on_shader_parameters(sprite, $Armor.BodyColors)
		

func set_new_colors_on_shader_parameters(object, new_colors) -> void :
	object.material.set_shader_param("R_MainColor1", new_colors[0])
	object.material.set_shader_param("R_MainColor2", new_colors[1])
	object.material.set_shader_param("R_MainColor3", new_colors[2])
	object.material.set_shader_param("R_MainColor4", new_colors[3])
	object.material.set_shader_param("R_MainColor5", new_colors[4])
	object.material.set_shader_param("R_MainColor6", new_colors[5])
	
func set_new_colors_for_armor_on_shader_parameters(object, new_colors) -> void :
	object.material.set_shader_param("R_MainColor2", new_colors[1])
	object.material.set_shader_param("R_MainColor3", new_colors[2])

func disable_collision():
	colliding = false
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
func enable_collision():
	colliding = true
	get_node("CollisionShape2D").set_deferred("disabled", false)

func is_colliding() -> bool:
	return colliding

func flash():
	if has_health():
		animatedSprite.material.set_shader_param("Flash", 1)
		flash_timer = 0.01
	
func end_flash():
	animatedSprite.material.set_shader_param("Flash", 0)
	flash_timer = 0

func are_low_walljump_raycasts_active() -> bool:
	var b: = true
	for raycast in low_jumpcasts:
		if not raycast.enabled:
			b = false
	return b

func activate_low_walljump_raycasts() -> void :
	for raycast in low_jumpcasts:
		raycast.enabled = true
	lowjumpcast.text = "on"

func deactivate_low_walljump_raycasts() -> void :
	for raycast in low_jumpcasts:
		raycast.enabled = false
	lowjumpcast.text = "off"

func set_global_position(new_position: Vector2) -> void :
	global_position = new_position

func start_dashfall() -> void :
	if not is_on_floor():
		dashfall = true

func set_x(pos) -> void :
	if can_be_moved():
		global_position.x = pos
func set_y(pos) -> void :
	if can_be_moved():
		global_position.y = pos

func move_x(difference) -> void :
	if can_be_moved():
		global_position.x += difference
func move_y(difference) -> void :
	if can_be_moved():
		global_position.y += difference

func can_be_moved() -> bool:
	return not is_executing("Ride")

func stop_forced_movement(forcer = null):
	if not is_executing("Ride"):
		emit_signal("stop_forced_movement", forcer)
		grabbed = false
