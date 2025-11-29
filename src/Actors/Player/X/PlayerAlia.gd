extends Character
class_name Alia

export  var skip_intro: bool = false

onready var lowjumpcast: Label = $lowjumpcast

var current_armor: Array = ["no_head", "no_body", "no_arms", "no_legs"]
var armor_sprites: Array = []
var flash_timer: float = 0.0
var block_charging: bool = false
var dashfall: bool = false
var dashjumps_since_jump: int = 0
var raycast_down: RayCast2D
var colliding: bool = true
var using_upgrades: bool = false
var grabbed: bool = false
var ride_eject_delay: float = 0.0
var ride: Node2D

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


func deactivate():
	stop_listening_to_inputs()
	stop_charge()
	stop_shot()
	
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
	save_original_colors()
	upgrades_buster()
	armor_sprites = get_armor_sprites()
	CharacterManager.weaponget = false
	if is_current_player:
		GameManager.set_player(self)
		Event.call_deferred("emit_signal", "player_set")

func get_armor_sprites() -> Array:
	var sprites = []
	for child in animatedSprite.get_children():
		if "armor" in child.name:
			sprites.append(child)
	return sprites

func _process(delta: float) -> void :
	if ride_eject_delay >= 0:
		ride_eject_delay -= delta
	process_flash(delta)

func process_flash(delta):
	if flash_timer > 0:
		flash_timer += delta
		if flash_timer > 0.034:
			end_flash()

func upgrades_buster():
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 0.5
	lifesteal.lifesteal_decay = 0.5
	lifesteal.minimum_time_between_heals = 0.2
	var cannon = get_node("Shot")
	cannon.upgraded = true
	cannon.update_list_of_weapons()

func is_full_armor() -> String:
	return "no_armor"

func equip_parts(collectible: String):
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
	get_node("Shot").unlock_weapon(collectible)
	
func get_current_weapon():
	return get_node("Shot").current_weapon

func is_heart(collectible: String) -> bool:
	return "heart" in collectible or "life" in collectible

func is_subtank(collectible: String) -> bool:
	return "tank" in collectible

func equip_heart() -> void :
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
	if CharacterManager.ultimate_x_armor:
		colors.append(animatedSprite.material.get_shader_param("MainColor1"))
		colors.append(animatedSprite.material.get_shader_param("MainColor2"))
		colors.append(animatedSprite.material.get_shader_param("MainColor3"))
		
		colors.append(animatedSprite.material.get_shader_param("MainColor4"))
		colors.append(animatedSprite.material.get_shader_param("MainColor5"))
		colors.append(animatedSprite.material.get_shader_param("MainColor6"))
		
		colors.append(animatedSprite.material.get_shader_param("CrystalColor1"))
		colors.append(animatedSprite.material.get_shader_param("CrystalColor2"))
		colors.append(animatedSprite.material.get_shader_param("CrystalColor3"))
		colors.append(animatedSprite.material.get_shader_param("CrystalColor4"))
		
		colors.append(animatedSprite.material.get_shader_param("ArmorColor1"))
		colors.append(animatedSprite.material.get_shader_param("ArmorColor2"))
		colors.append(animatedSprite.material.get_shader_param("ArmorColor3"))
	else:
		colors.append(animatedSprite.material.get_shader_param("MainColor1"))
		colors.append(animatedSprite.material.get_shader_param("MainColor2"))
		colors.append(animatedSprite.material.get_shader_param("MainColor3"))
		colors.append(animatedSprite.material.get_shader_param("MainColor4"))
		colors.append(animatedSprite.material.get_shader_param("MainColor5"))
		colors.append(animatedSprite.material.get_shader_param("MainColor6"))

func change_palette(new_colors, paint_armor: = true):
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	if CharacterManager.ultimate_x_armor:
		if paint_armor:
			set_new_colors_on_shader_parameters(animatedSprite, new_colors)
		else:
			reset_colors_for_armor_on_shader_parameters(animatedSprite)
	else:
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

func reset_colors_for_armor_on_shader_parameters(object) -> void :
	object.material.set_shader_param("R_MainColor1", Color("#4d547d"))
	object.material.set_shader_param("R_MainColor2", Color("#29345b"))
	object.material.set_shader_param("R_MainColor3", Color("#132247"))
	
	object.material.set_shader_param("R_MainColor4", Color("#687ccc"))
	object.material.set_shader_param("R_MainColor5", Color("#506090"))
	object.material.set_shader_param("R_MainColor6", Color("#2c3956"))
	
	object.material.set_shader_param("R_CrystalColor1", Color("#d77be6"))
	object.material.set_shader_param("R_CrystalColor2", Color("#8d2bba"))
	object.material.set_shader_param("R_CrystalColor3", Color("#60008d"))
	object.material.set_shader_param("R_CrystalColor4", Color("#ffb4ff"))
	
	object.material.set_shader_param("R_ArmorColor1", Color("#e8e040"))
	object.material.set_shader_param("R_ArmorColor2", Color("#f19946"))
	object.material.set_shader_param("R_ArmorColor3", Color("#ab5044"))

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
