extends Node

onready var _PLAYER: PackedScene = preload("res://src/Actors/Player/Player.tscn")
onready var _X: PackedScene = preload("res://src/Actors/Player/X/PlayerX.tscn")
onready var _X_Ultimate: PackedScene = preload("res://X_mod/UltimateX/Player/UltimateX.tscn")
onready var _Axl: PackedScene = preload("res://Axl_mod/Player/PlayerAxl.tscn")
onready var _Floppa_Axl: PackedScene = preload("res://Axl_mod/Player/PlayerFloppaAxl.tscn")
onready var _Zero_Beta: PackedScene = preload("res://Zero_mod/Player/PlayerZero.tscn")
onready var _Zero: PackedScene = preload("res://Zero_mod/X8/Player/PlayerZeroX8.tscn")
onready var _Alia: PackedScene = preload("res://src/Actors/Player/X/PlayerAlia.tscn")
onready var _Layer: PackedScene = preload("res://Zero_mod/X8/Player/PlayerLayer.tscn")
onready var _Pallette: PackedScene = preload("res://Axl_mod/Player/PlayerPallette.tscn")

var DEBUG: bool = false
var teleport_to_boss: bool = false
var delay: float = 0.0
var hold_reset: float = 0.0

var new_game: bool = true
var NO_MOVEMENT_CHALLENGE: bool = false

var player_count: int = 1
const min_player_count: int = 1
const max_player_count: int = 6

var ultimate_x_armor: bool = false
var black_zero_armor: bool = false
var white_axl_armor: bool = false


var betazero_unlocked: bool = false
var betazero_activated: bool = false
var nightshade_zero_armor: bool = false

var only_x: bool = false
var auto_charge: bool = false
var rapid_fire: bool = false
var ultimate_buster: bool = false
var charge_max: bool = false
var xdrive: bool = false
var weaponget: bool = false

var started_fresh_game: bool = false
var only_zero: bool = false
var awakened_zero_armor: bool = false
var awakened_zero_unlocked: bool = false
var custom_zero_armor: bool = false
var awakened_zero_full_power_max: bool = false
var extra_saber_combo: bool = false
var extra_saber_color: bool = false
var extra_saber_01: bool = false
var extra_saber_02: bool = false
var extra_saber_03: bool = false
var extra_saber_04: bool = false
var axl_first_time: bool = false
var axl_second_time: bool = false
var buster_base_energy: int = 20

var custom_axl_armor: bool = false
var only_axl: bool = false
var floppa_axl_unlocked: bool = false
var floppa_axl_activated: bool = false
var floppa_axl_auto_hover: bool = false
var floppa_axl_auto_cling_wall: bool = false
var floppa_axl_auto_lock: bool = false

var tenshouha_active: bool = true
var juuhazan_active: bool = true
var rasetsusen_active: bool = true
var raikousen_active: bool = true
var youdantotsu_active: bool = true
var rekkyoudan_active: bool = true
var hyouryuushou_active: bool = true
var enkoujin_active: bool = true

###Android Control Test###
var pause_position_x: int = 2150
var pause_position_y: int = 0

var jump_position_x: int = 3840
var jump_position_y: int = 1760
var dash_position_x: int = 3840
var dash_position_y: int = 1360

var fire_position_x: int = 3440
var fire_position_y: int = 1760
var alt_fire_position_x: int = 3440
var alt_fire_position_y: int = 1360

var special_position_x: int = 3440
var special_position_y: int = 560
var switch_position_x: int = 3840
var switch_position_y: int = 560

var dash_jump_position_x: int = 3440
var dash_jump_position_y: int = 960
var dash_fire_position_x: int = 3840
var dash_fire_position_y: int = 960

var weapon_left_position_x: int = 320
var weapon_left_position_y: int = 0
var weapon_right_position_x: int = 3740
var weapon_right_position_y: int = 0

var joystick_position_x: int = 910
var joystick_position_y: int = 1660

var weaponround_position_x: int = 3310
var weaponround_position_y: int = 300
###Android Control Test###

# Character/team management stuff

var player_character: String = "X"

var valid_players: Array = ["X", "Zero", "Axl", "Alia", "Layer", "Pallette"]

var equipped_hearts: Dictionary = {"X": 0, "Zero": 0, "Axl": 0, "Alia": 0, "Layer": 0, "Pallette": 0}
var heart_tank_buff_amt: int = 2
var starting_max_health: int = 16

var both_alive = true
var alive_team: Array = []

var team: Array = ["X"]
var max_team_size: int = 2

var switch_cooldown_duration: float = 0.3
var switch_timer: float = 0
var switch_invulnerability_duration: float = 0.75
var switch_invulnerability_timer: float = 0

func on_character_switch_end():
	team.invert()
	if not GameManager.player.is_on_floor():
		# Reset horizontal velocity and remove dash/jump/hover abilities from the switching character
		GameManager.player.dashfall = false
		GameManager.player.max_out_air_abilities()

	GameManager.player.pause_mode = PAUSE_MODE_INHERIT
	GameManager.inactive_player.pause_mode = PAUSE_MODE_INHERIT
	GameManager.unpause("CharacterSwitch")
	switch_timer = switch_cooldown_duration
	if not both_alive:
		GameManager.player.add_invulnerability("character_switch")
		switch_invulnerability_timer = switch_invulnerability_duration

var finished_switching = 0
func try_character_switch_end():
	finished_switching += 1
	if finished_switching == 2:
		finished_switching = 0
		Event.emit_signal("character_switch_end")

func get_heart_count() -> int:
	var count = 0
	for item in GameManager.collectibles:
		if "life_up" in item:
			count += max_player_count
	return count

func are_hearts_equipped() -> bool:
	var sum = 0
	for key in equipped_hearts.keys():
		sum += equipped_hearts[key]
	return bool(sum)

func reset_equipped_hearts() -> void:
	equipped_hearts = {"X": 0, "Zero": 0, "Axl": 0, "Alia": 0, "Layer": 0, "Pallette": 0}

func set_player_equipped_hearts(name: String, num_to_equip: int) -> void:
	var max_hearts = get_heart_count()
	var new_equipped_heart_count = 0

	if num_to_equip < 0:
		num_to_equip = 0
	elif num_to_equip > max_hearts/max_player_count:
		num_to_equip = max_hearts/max_player_count

	for key in equipped_hearts.keys():
		if key == name:
			new_equipped_heart_count += num_to_equip
		else:
			new_equipped_heart_count += equipped_hearts[key]

	if new_equipped_heart_count <= max_hearts:
		equipped_hearts[name] = num_to_equip


func add_player_to_team(new_player: String) -> void:
	if new_player in valid_players and team.size() < max_team_size:
		team.append(new_player)

func remove_player_from_team(player_to_remove: String) -> void:
	team.erase(player_to_remove)


func set_player_character(character) -> void :
	match character:
		"Player":
			player_count = 0
		"X":
			player_count = 1
		"Zero":
			player_count = 2
		"Axl":
			player_count = 3
		"Alia":
			player_count = 4
		"Layer":
			player_count = 5
		"Pallette":
			player_count = 6
		_:
			player_count = 0
	player_character = character;

func assign_name_to_player_counter(count) -> void :
	var _player_ins = _PLAYER.instance()
	if count == 0:
		_player_ins = _PLAYER.instance()
	elif count == 1:
		_player_ins = _X.instance()
		if ultimate_x_armor:
			_player_ins = _X_Ultimate.instance()
	elif count == 2:
		_player_ins = _Zero.instance()
	elif count == 3:
		_player_ins = _Axl.instance()
	elif count == 4:
		_player_ins = _Alia.instance()
	elif count == 5:
		_player_ins = _Layer.instance()
	elif count == 6:
		_player_ins = _Pallette.instance()
	player_character = _player_ins.name
	_player_ins.queue_free()

func get_player_character_object(character_str) -> PackedScene:
	match character_str:
		"Player":
			return _PLAYER
		"X":
			if ultimate_x_armor:
				return _X_Ultimate
			return _X
		"Axl":
			if floppa_axl_activated:
				if not weaponget:
					return _Floppa_Axl
			return _Axl
		"Zero":
			if betazero_activated:
				return _Zero_Beta
			return _Zero
		"Alia":
			return _Alia
		"Layer":
			return _Layer
		"Pallette":
			return _Pallette
		_:
			return _PLAYER

func get_player_character_string() -> String:
	return player_character

#######

var elevator_walls_y: float = 0.0
var credits_seen: bool = false

var CURRENT_EVENT: int = 0
var EVENT_MESSAGE: String = ""

var DISCLAIMER_ACCPETED: bool = false
var DISCLAIMER_EU: bool = false
var LOGGED_IN: bool = false


var touch_controls: bool = false
func is_Android() -> bool:
	if OS.get_name() == "Android":
		return true
	return false
func touch_controls_enabled() -> bool:
	if is_Android():
		return touch_controls
	return false


const char_data: String = "user://char_data"
func _save() -> void :
	var save_data = {
		"player_count": player_count, 
		"player_character": player_character, 
		"credits_seen": credits_seen, 
		
		"new_game": new_game, 
		"beaten_hard": beaten_hard, 
		"beaten_insanity": beaten_insanity, 
		"beaten_ninjagaiden": beaten_ninjagaiden,
		
		"auto_charge": auto_charge, 
		"rapid_fire": rapid_fire, 
		"ultimate_buster": ultimate_buster, 
		#"buster_base_energy": buster_base_energy, 
		
		"extra_saber_combo": extra_saber_combo, 
		"extra_saber_color": extra_saber_color, 
		"custom_zero_armor": custom_zero_armor,
		"extra_saber_01": extra_saber_01, 
		"extra_saber_02": extra_saber_02, 
		"extra_saber_03": extra_saber_03, 
		"extra_saber_04": extra_saber_04, 
		"axl_first_time": axl_first_time, 
		"axl_second_time": axl_second_time, 
		
		"beta_zero_unlocked": betazero_unlocked, 
		"beta_zero_activated": betazero_activated, 
		
		"awakened_zero_unlocked": awakened_zero_unlocked,
		"awakened_zero_armor": awakened_zero_armor,
		"awakened_zero_full_power_max": awakened_zero_full_power_max, 
		
		"custom_axl_armor": custom_axl_armor,
		"floppa_axl_unlocked": floppa_axl_unlocked,
		"floppa_axl_activated": floppa_axl_activated,
		"floppa_axl_auto_hover": floppa_axl_auto_hover,
		"floppa_axl_auto_cling_wall": floppa_axl_auto_cling_wall,
		"floppa_axl_auto_lock": floppa_axl_auto_lock,
		
		"ultimate_x_armor": ultimate_x_armor, 
		"black_zero_armor": black_zero_armor, 
		"white_axl_armor": white_axl_armor, 

		"pause_position_x": pause_position_x, 
		"pause_position_y": pause_position_y, 
		"jump_position_x": jump_position_x, 
		"jump_position_y": jump_position_y, 
		"dash_position_x": dash_position_x, 
		"dash_position_y": dash_position_y, 
		"fire_position_x": fire_position_x, 
		"fire_position_y": fire_position_y, 
		"alt_fire_position_x": alt_fire_position_x, 
		"alt_fire_position_y": alt_fire_position_y, 
		"special_position_x": special_position_x, 
		"special_position_y": special_position_y, 
		"switch_position_x": switch_position_x, 
		"switch_position_y": switch_position_y, 
		"dash_jump_position_x": dash_jump_position_x, 
		"dash_jump_position_y": dash_jump_position_y, 
		"dash_fire_position_x": dash_fire_position_x, 
		"dash_fire_position_y": dash_fire_position_y, 
		"weapon_left_position_x": weapon_left_position_x, 
		"weapon_left_position_y": weapon_left_position_y, 
		"weapon_right_position_x": weapon_right_position_x, 
		"weapon_right_position_y": weapon_right_position_y, 
		"joystick_position_x": joystick_position_x, 
		"joystick_position_y": joystick_position_y, 
		"weaponround_position_x": weaponround_position_x, 
		"weaponround_position_y": weaponround_position_y, 
	}
	var bson = BSON.to_bson(save_data)
	
	var file = File.new()
	if file.open(char_data, File.WRITE) == OK:
		file.store_buffer(bson)
		file.close()

func _load() -> void :
	var file = File.new()
	if file.file_exists(char_data):
		file.open(char_data, File.READ)
		var bson = file.get_buffer(file.get_len())
		file.close()
		
		var save_data = BSON.from_bson(bson)
		
		if typeof(save_data) == TYPE_DICTIONARY:
			player_count = int(save_data.get("player_count", 1))
			player_character = save_data.get("player_character", "X")
			credits_seen = bool(save_data.get("credits_seen", false))
			
			new_game = bool(save_data.get("new_game", true))
			beaten_hard = bool(save_data.get("beaten_hard", false))
			beaten_insanity = bool(save_data.get("beaten_insanity", false))
			beaten_ninjagaiden = bool(save_data.get("beaten_ninjagaiden",false))
			
			auto_charge = bool(save_data.get("auto_charge", false))
			rapid_fire = bool(save_data.get("rapid_fire", false))
			ultimate_buster = bool(save_data.get("ultimate_buster", false))
			#buster_base_energy = int(save_data.get("buster_base_energy", 20))
			
			extra_saber_combo = bool(save_data.get("extra_saber_combo", false))
			extra_saber_color = bool(save_data.get("extra_saber_color",false))
			custom_zero_armor = bool(save_data.get("custom_zero_armor",false))
			
			betazero_unlocked = bool(save_data.get("beta_zero_unlocked", false))
			betazero_activated = bool(save_data.get("beta_zero_activated", false))
			
			awakened_zero_unlocked = bool(save_data.get("awakened_zero_unlocked",false))
			awakened_zero_full_power_max = bool(save_data.get("awakened_zero_full_power_max",false))
			
			custom_axl_armor = bool(save_data.get("custom_axl_armor",false))
			
			floppa_axl_unlocked = bool(save_data.get("floppa_axl_unlocked",false))
			floppa_axl_auto_hover = bool(save_data.get("floppa_axl_auto_hover",false))
			floppa_axl_auto_cling_wall = bool(save_data.get("floppa_axl_auto_cling_wall",false))
			floppa_axl_auto_lock = bool(save_data.get("floppa_axl_auto_lock",false))
			
			if "ultima_head" in GameManager.collectibles:
				if evaluate_ultimate_armor_state():
					ultimate_x_armor = bool(save_data.get("ultimate_x_armor", false))
			else:
				ultimate_x_armor = false
				
			if "black_zero_armor" in GameManager.collectibles:
				black_zero_armor = bool(save_data.get("black_zero_armor", false))
			else:
				black_zero_armor = false
				
			if "extra_saber_combo" in GameManager.collectibles:
				extra_saber_combo = bool(save_data.get("extra_saber_combo", false))
				extra_saber_01 = bool(save_data.get("extra_saber_01", false))
				extra_saber_02 = bool(save_data.get("extra_saber_02", false))
				extra_saber_03 = bool(save_data.get("extra_saber_03", false))
				extra_saber_04 = bool(save_data.get("extra_saber_04", false))
			else:
				extra_saber_combo = false
				extra_saber_01 = false
				extra_saber_02 = false
				extra_saber_03 = false
				extra_saber_04 = false
				
			if "awakened_zero_armor" in GameManager.collectibles or CharacterManager.awakened_zero_unlocked:
				awakened_zero_armor = bool(save_data.get("awakened_zero_armor", false))
			else:
				awakened_zero_armor = false
				
			if "floppa_axl_activated" in GameManager.collectibles or CharacterManager.floppa_axl_unlocked:
				floppa_axl_activated = bool(save_data.get("floppa_axl_activated", false))
			else:
				floppa_axl_activated = false
			
			if "white_axl_armor" in GameManager.collectibles:
				white_axl_armor = bool(save_data.get("white_axl_armor", false))
			else:
				white_axl_armor = false
			
			pause_position_x = int(save_data.get("pause_position_x", 2150))
			pause_position_y = int(save_data.get("pause_position_y", 0))
			jump_position_x = int(save_data.get("jump_position_x", 3840))
			jump_position_y = int(save_data.get("jump_position_y", 1760))
			dash_position_x = int(save_data.get("dash_position_x", 3840))
			dash_position_y = int(save_data.get("dash_position_y", 1360))
			fire_position_x = int(save_data.get("fire_position_x", 3440))
			fire_position_y = int(save_data.get("fire_position_y", 1760))
			alt_fire_position_x = int(save_data.get("alt_fire_position_x", 3440))
			alt_fire_position_y = int(save_data.get("alt_fire_position_y", 1360))
			special_position_x = int(save_data.get("special_position_x", 3440))
			special_position_y = int(save_data.get("special_position_y", 560))
			switch_position_x = int(save_data.get("switch_position_x", 3840))
			switch_position_y = int(save_data.get("switch_position_y", 560))
			dash_jump_position_x = int(save_data.get("dash_jump_position_x", 3440))
			dash_jump_position_y = int(save_data.get("dash_jump_position_y", 960))
			dash_fire_position_x = int(save_data.get("dash_fire_position_x", 3840))
			dash_fire_position_y = int(save_data.get("dash_fire_position_y", 960))
			weapon_left_position_x = int(save_data.get("weapon_left_position_x", 320))
			weapon_left_position_y = int(save_data.get("weapon_left_position_y", 0))
			weapon_right_position_x = int(save_data.get("weapon_right_position_x", 3740))
			weapon_right_position_y = int(save_data.get("weapon_right_position_y", 0))
			joystick_position_x = int(save_data.get("joystick_position_x", 910))
			joystick_position_y = int(save_data.get("joystick_position_y", 1660))
			weaponround_position_x = int(save_data.get("weaponround_position_x", 3310))
			weaponround_position_y = int(save_data.get("weaponround_position_y", 300))

	update_game_mode()
	check_for_deactivated_skills_Zero()
	
	

func evaluate_ultimate_armor_state() -> bool:
	var required_parts = ["head", "body", "arms", "legs"]
	var found_parts = []
	var i = GameManager.collectibles.size() - 1
	while i >= 0 and found_parts.size() < 4:
		var item = GameManager.collectibles[i]
		if item.begins_with("icarus") or item.begins_with("hermes"):
			return false
		if item.begins_with("ultima"):
			var part = get_body_part_name(item)
			if part in found_parts:
				return false
			found_parts.append(part)
		i -= 1
		
	if found_parts.size() == 4 and found_parts.sort() == required_parts.sort():
		return true
	return false

func get_body_part_name(collectible_name: String) -> String:
	if collectible_name.length() <= 4:
		return collectible_name
	return collectible_name.substr(7)


func _ready() -> void :

	set_process(true)
	pause_mode = PAUSE_MODE_PROCESS
	Event.listen("character_switch_end", self, "on_character_switch_end")

func _process(_delta: float) -> void :
#	if started_fresh_game:
#		if game_mode >= 3:
#			if player_character != "Zero":
#				only_zero = false
	if switch_timer > 0:
		switch_timer -= _delta
	if switch_invulnerability_timer > 0:
		switch_invulnerability_timer -= _delta
		if switch_invulnerability_timer <= 0:
			GameManager.player.remove_invulnerability("character_switch")
	

var beaten_hard: bool = false
var beaten_insanity: bool = false
var beaten_ninjagaiden: bool = false
var game_mode_set: bool = false
var damage_deal_multiplier: float = 1.0
var damage_get_multiplier: float = 1.0
var boss_ai_multiplier: float = 1.0
var boss_damage_reduction: float = 1.0
var game_mode: int = 0
var GAME_MODE: String = ""
var game_mode_stats: Dictionary = {
	- 1: {"deal": 1.0, "get": 0.75, "bossai": 2.0, "bossreduction": 0.75}, 
		0: {"deal": 1.0, "get": 1.0, "bossai": 1.0, "bossreduction": 0.5}, 
		1: {"deal": 0.8, "get": 1.2, "bossai": 0.8, "bossreduction": 0.25}, 
		2: {"deal": 0.5, "get": 1.5, "bossai": 0.5, "bossreduction": 0.0}, 
		3: {"deal": 0.5, "get": 5.0, "bossai": 0.0, "bossreduction": 0.0}
}
func update_game_mode() -> void :
	
	if game_mode == - 1:
		GAME_MODE = "GAME_START_ROOKIE"
		set_drop_rate(75, 10, 35, 5, 15, 1)
	elif game_mode == 0:
		GAME_MODE = "GAME_START_NORMAL"
		set_drop_rate(25, 30, 15, 15, 10, 0.1)
	elif game_mode == 1:
		GAME_MODE = "GAME_START_HARD"
		set_drop_rate(15, 20, 10, 10, 10, 0.1)
	elif game_mode == 2:
		GAME_MODE = "GAME_START_INSANITY"
		set_drop_rate(5, 10, 5, 10, 5, 0)
	elif game_mode >= 3:
		GAME_MODE = "GAME_START_NINJA"
		set_drop_rate(0, 0, 0, 0, 0, 0)
	var stats = game_mode_stats.get(game_mode, {"deal": 1.0, "get": 1.0, "bossai": 1.0, "bossreduction": 1.0})
	damage_deal_multiplier = stats["deal"]
	damage_get_multiplier = stats["get"]
	boss_ai_multiplier = stats["bossai"]
	boss_damage_reduction = stats["bossreduction"]

func set_drop_rate(
	drop_item_chance = 25, 
	small_health_chance = 30, 
	big_health_chance = 15, 
	small_ammo_chance = 15, 
	big_ammo_chance = 10, 
	extra_life_chance = 0.1
) -> void :
	GameManager.drop_item_chance_default = drop_item_chance
	GameManager.small_health_chance_default = small_health_chance
	GameManager.big_health_chance_default = big_health_chance
	GameManager.small_ammo_chance_default = small_ammo_chance
	GameManager.big_ammo_chance_default = big_ammo_chance
	GameManager.extra_life_chance_default = extra_life_chance


func add_all_armors() -> void :
	
	GameManager.add_collectible_to_savedata("icarus_head")
	GameManager.add_collectible_to_savedata("icarus_body")
	GameManager.add_collectible_to_savedata("icarus_arms")
	GameManager.add_collectible_to_savedata("icarus_legs")
	GameManager.add_collectible_to_savedata("hermes_head")
	GameManager.add_collectible_to_savedata("hermes_body")
	GameManager.add_collectible_to_savedata("hermes_arms")
	GameManager.add_collectible_to_savedata("hermes_legs")
	GameManager.add_collectible_to_savedata("ultima_head")
	GameManager.add_collectible_to_savedata("ultima_body")
	GameManager.add_collectible_to_savedata("ultima_arms")
	GameManager.add_collectible_to_savedata("ultima_legs")
	GameManager.add_collectible_to_savedata("black_zero_armor")
	GameManager.add_collectible_to_savedata("white_axl_armor")

func add_subtanks() -> void :
	GameManager.add_collectible_to_savedata("subtank_trilobyte")
	GameManager.add_collectible_to_savedata("subtank_sunflower")
	GameManager.add_collectible_to_savedata("subtank_yeti")
	GameManager.add_collectible_to_savedata("subtank_rooster")

func add_hearttanks() -> void :
	GameManager.add_collectible_to_savedata("life_up_panda")
	GameManager.add_collectible_to_savedata("life_up_sunflower")
	GameManager.add_collectible_to_savedata("life_up_trilobyte")
	GameManager.add_collectible_to_savedata("life_up_manowar")
	GameManager.add_collectible_to_savedata("life_up_yeti")
	GameManager.add_collectible_to_savedata("life_up_rooster")
	GameManager.add_collectible_to_savedata("life_up_antonion")
	GameManager.add_collectible_to_savedata("life_up_mantis")
	GameManager.add_collectible_to_savedata("life_up_ex1")
	GameManager.add_collectible_to_savedata("life_up_ex2")
	GameManager.add_collectible_to_savedata("life_up_ex3")
	GameManager.add_collectible_to_savedata("life_up_ex4")

func remove_all_zero_weapons() -> void :
	GameManager.remove_collectible_from_savedata("b_fan_zero")
	GameManager.remove_collectible_from_savedata("d_glaive_zero")
	GameManager.remove_collectible_from_savedata("k_knuckle_zero")
	GameManager.remove_collectible_from_savedata("t_breaker_zero")

	GameManager.remove_collectible_from_savedata("z_breaker_zero")
	GameManager.remove_collectible_from_savedata("rogue_blade_zero")
	GameManager.remove_collectible_from_savedata("v_hanger_zero")
	GameManager.remove_collectible_from_savedata("sigma_blade_zero")

func clear_subtanks() -> void :
	GameManager.remove_collectible_from_savedata("subtank_trilobyte")
	GameManager.remove_collectible_from_savedata("subtank_sunflower")
	GameManager.remove_collectible_from_savedata("subtank_yeti")
	GameManager.remove_collectible_from_savedata("subtank_rooster")

func clear_hearttanks() -> void :
	GameManager.remove_collectible_from_savedata("life_up_panda")
	GameManager.remove_collectible_from_savedata("life_up_sunflower")
	GameManager.remove_collectible_from_savedata("life_up_trilobyte")
	GameManager.remove_collectible_from_savedata("life_up_manowar")
	GameManager.remove_collectible_from_savedata("life_up_yeti")
	GameManager.remove_collectible_from_savedata("life_up_rooster")
	GameManager.remove_collectible_from_savedata("life_up_antonion")
	GameManager.remove_collectible_from_savedata("life_up_mantis")
	GameManager.remove_collectible_from_savedata("life_up_ex1")
	GameManager.remove_collectible_from_savedata("life_up_ex2")
	GameManager.remove_collectible_from_savedata("life_up_ex3")
	GameManager.remove_collectible_from_savedata("life_up_ex4")


func unlocked_boss_weapon() -> bool:
	if is_instance_valid(GameManager.player):
		var shot = GameManager.player.get_node("Shot")
		if GameManager.player.name == "Axl":
			for child in shot.get_children():
				if child is WeaponBossAxl:
					if child.active:
						return true
	return false

func reset_material(material: ShaderMaterial) -> void :
	if material != null:
		var new_material = ShaderMaterial.new()
		new_material.shader = material.shader
		material = new_material

func set_axl_colors(node) -> void :
	if white_axl_armor:
		set_white_axl_colors(node)
	else:
		set_axl_normal_colors(node)
	if floppa_axl_activated:
		set_axl_floppa_colors(node)
	if custom_axl_armor:
		set_custom_axl_colors(node)

func set_pallette_colors(node) -> void :
	if white_axl_armor:
		set_axl_normal_colors(node)
	else:
		set_axl_normal_colors(node)

func set_axl_normal_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_AxlOutlineColor", Color("#181818"))
		
		node.material.set_shader_param("R_AxlMainColor1", Color("#51688c"))
		node.material.set_shader_param("R_AxlMainColor2", Color("#404964"))
		node.material.set_shader_param("R_AxlMainColor3", Color("#2d3344"))
		
		node.material.set_shader_param("R_AxlMainColor4", Color("#b0b0b0"))
		node.material.set_shader_param("R_AxlMainColor5", Color("#807880"))
		node.material.set_shader_param("R_AxlMainColor6", Color("#605960"))
		
		node.material.set_shader_param("R_GleyColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_GleyColor2", Color("#A0A0A0"))
		
		node.material.set_shader_param("R_AxlCrystalColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_AxlCrystalColor2", Color("#4f8eee"))
		node.material.set_shader_param("R_AxlCrystalColor3", Color("#1258c2"))
		
		node.material.set_shader_param("R_AxlHairColor1", Color("#ff6318"))
		node.material.set_shader_param("R_AxlHairColor2", Color("#ce3910"))
		node.material.set_shader_param("R_AxlHairColor3", Color("#8c2900"))
		
		node.material.set_shader_param("R_AxlYellowColor1", Color("#f8d820"))
		node.material.set_shader_param("R_AxlYellowColor2", Color("#cb8925"))
		
		node.material.set_shader_param("R_AxlRedColor1", Color("#db3b3d"))
		node.material.set_shader_param("R_AxlRedColor2", Color("#8c1a1f"))
		
		node.material.set_shader_param("R_AxlFlameColor1", Color("#ef6649"))
		node.material.set_shader_param("R_AxlFlameColor2", Color("#c72c23"))
		node.material.set_shader_param("R_AxlFlameColor3", Color("#9f221c"))
		
		node.material.set_shader_param("R_AxlSkinColor1", Color("#F5B57D"))
		node.material.set_shader_param("R_AxlSkinColor2", Color("#B86048"))
		node.material.set_shader_param("R_AxlSkinColor3", Color("#804020"))
		
		node.material.set_shader_param("R_AxlAfterimagesColor1", Color("#51688c"))
		node.material.set_shader_param("R_AxlAfterimagesColor2", Color("#8c1a1f"))

func set_axl_floppa_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_AxlOutlineColor", Color("#1e201f"))
		
		node.material.set_shader_param("R_AxlMainColor1", Color("#857284"))
		node.material.set_shader_param("R_AxlMainColor2", Color("#573f6e"))
		node.material.set_shader_param("R_AxlMainColor3", Color("#322738"))
		
		node.material.set_shader_param("R_AxlMainColor4", Color("#b0b0b0"))
		node.material.set_shader_param("R_AxlMainColor5", Color("#807880"))
		node.material.set_shader_param("R_AxlMainColor6", Color("#605960"))
		
		node.material.set_shader_param("R_GleyColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_GleyColor2", Color("#A0A0A0"))
		
		node.material.set_shader_param("R_AxlCrystalColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_AxlCrystalColor2", Color("#4f8eee"))
		node.material.set_shader_param("R_AxlCrystalColor3", Color("#1258c2"))
		
		node.material.set_shader_param("R_AxlHairColor1", Color("#ff6318"))
		node.material.set_shader_param("R_AxlHairColor2", Color("#ce3910"))
		node.material.set_shader_param("R_AxlHairColor3", Color("#8c2900"))
		
		node.material.set_shader_param("R_AxlYellowColor1", Color("#f8d820"))
		node.material.set_shader_param("R_AxlYellowColor2", Color("#cb8925"))
		
		node.material.set_shader_param("R_AxlRedColor1", Color("#db3b3d"))
		node.material.set_shader_param("R_AxlRedColor2", Color("#8c1a1f"))
		
		node.material.set_shader_param("R_AxlFlameColor1", Color("#ef6649"))
		node.material.set_shader_param("R_AxlFlameColor2", Color("#c72c23"))
		node.material.set_shader_param("R_AxlFlameColor3", Color("#9f221c"))
		
		node.material.set_shader_param("R_AxlSkinColor1", Color("#F5B57D"))
		node.material.set_shader_param("R_AxlSkinColor2", Color("#B86048"))
		node.material.set_shader_param("R_AxlSkinColor3", Color("#804020"))
		
		node.material.set_shader_param("R_AxlAfterimagesColor1", Color("#4f8eee"))
		node.material.set_shader_param("R_AxlAfterimagesColor2", Color("#1258c2"))

func set_white_axl_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_AxlOutlineColor", Color("#181818"))
		
		node.material.set_shader_param("R_AxlMainColor1", Color("#DCE0FF"))
		node.material.set_shader_param("R_AxlMainColor2", Color("#A0A8BC"))
		node.material.set_shader_param("R_AxlMainColor3", Color("#4C5870"))
		
		node.material.set_shader_param("R_AxlMainColor4", Color("#C6B0CE"))
		node.material.set_shader_param("R_AxlMainColor5", Color("#AB89AC"))
		node.material.set_shader_param("R_AxlMainColor6", Color("#7E6380"))
		
		node.material.set_shader_param("R_GleyColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_GleyColor2", Color("#A0A0A0"))
		
		node.material.set_shader_param("R_AxlCrystalColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_AxlCrystalColor2", Color("#63E2EA"))
		node.material.set_shader_param("R_AxlCrystalColor3", Color("#50B5F4"))
		
		node.material.set_shader_param("R_AxlHairColor1", Color("#AA77DB"))
		node.material.set_shader_param("R_AxlHairColor2", Color("#8C59BD"))
		node.material.set_shader_param("R_AxlHairColor3", Color("#6318A5"))
		
		node.material.set_shader_param("R_AxlYellowColor1", Color("#0DD84A"))
		node.material.set_shader_param("R_AxlYellowColor2", Color("#0E9F39"))
		
		node.material.set_shader_param("R_AxlRedColor1", Color("#8C59BD"))
		node.material.set_shader_param("R_AxlRedColor2", Color("#6318A5"))
		
		node.material.set_shader_param("R_AxlFlameColor1", Color("#A269DB"))
		node.material.set_shader_param("R_AxlFlameColor2", Color("#731DC4"))
		node.material.set_shader_param("R_AxlFlameColor3", Color("#4F1487"))
		
		node.material.set_shader_param("R_AxlSkinColor1", Color("#F5B57D"))
		node.material.set_shader_param("R_AxlSkinColor2", Color("#B86048"))
		node.material.set_shader_param("R_AxlSkinColor3", Color("#804020"))
		
		node.material.set_shader_param("R_AxlAfterimagesColor1", Color("#DCE0FF"))
		node.material.set_shader_param("R_AxlAfterimagesColor2", Color("#6318A5"))

func set_zero_colors(node):
	if black_zero_armor:
		set_new_betazero_black_colors(node)
	else:
		set_new_betazero_normal_colors(node)
	if custom_zero_armor:
		customzerocolor()
		displaycolor(node)

func set_zero_normal_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_AuraColor", Color("#cc1b00"))
		node.material.set_shader_param("R_LightRedColor1", Color("#ff5959"))
		node.material.set_shader_param("R_MainColor1", Color("#e02000"))
		node.material.set_shader_param("R_MainColor2", Color("#a02000"))
		node.material.set_shader_param("R_MainColor3", Color("#602000"))
		
		node.material.set_shader_param("R_MainColor4", Color("#e0c000"))
		node.material.set_shader_param("R_MainColor5", Color("#a06000"))
		node.material.set_shader_param("R_MainColor6", Color("#6f4200"))
		node.material.set_shader_param("R_HairColor", Color("#6f4200"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#f8b080"))
		node.material.set_shader_param("R_SkinColor2", Color("#b86048"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b3118"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#60a0e0"))
		node.material.set_shader_param("R_CrystalColor3", Color("#0040a0"))
		
		node.material.set_shader_param("R_GreenColor1", Color("#40e040"))
		node.material.set_shader_param("R_GreenColor2", Color("#20a020"))
		
		node.material.set_shader_param("R_OutlineColor", Color("#202020"))
		
		node.material.set_shader_param("R_SaberColor0", Color("#e7e7e7"))
		node.material.set_shader_param("R_SaberColor1", Color("#a0e080"))
		node.material.set_shader_param("R_SaberColor2", Color("#60e040"))
		node.material.set_shader_param("R_SaberColor3", Color("#40c040"))
		node.material.set_shader_param("R_SaberColor4", Color("#42a542"))

func set_black_zero_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_AuraColor", Color("#a068c0"))
		
		node.material.set_shader_param("R_LightRedColor1", Color("#595959"))
		node.material.set_shader_param("R_MainColor1", Color("#484848"))
		node.material.set_shader_param("R_MainColor2", Color("#303030"))
		node.material.set_shader_param("R_MainColor3", Color("#181818"))

		node.material.set_shader_param("R_MainColor4", Color("#c8b898"))
		node.material.set_shader_param("R_MainColor5", Color("#a88868"))
		node.material.set_shader_param("R_MainColor6", Color("#786050"))
		node.material.set_shader_param("R_HairColor", Color("#786050"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#f8b080"))
		node.material.set_shader_param("R_SkinColor2", Color("#b86048"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b3118"))

		node.material.set_shader_param("R_CrystalColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#60a0e0"))
		node.material.set_shader_param("R_CrystalColor3", Color("#0040a0"))

		node.material.set_shader_param("R_GreenColor1", Color("#40e040"))
		node.material.set_shader_param("R_GreenColor2", Color("#20a020"))

		node.material.set_shader_param("R_OutlineColor", Color("#0e111e"))

		node.material.set_shader_param("R_SaberColor0", Color("#e7e7e7"))
		node.material.set_shader_param("R_SaberColor1", Color("#e0d0e8"))
		node.material.set_shader_param("R_SaberColor2", Color("#c8b0d8"))
		node.material.set_shader_param("R_SaberColor3", Color("#b888d0"))
		node.material.set_shader_param("R_SaberColor4", Color("#a068c0"))

func set_fake_zero_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_AuraColor", Color("#941008"))
		node.material.set_shader_param("R_LightRedColor1", Color("#606860"))
		node.material.set_shader_param("R_MainColor1", Color("#606860"))
		node.material.set_shader_param("R_MainColor2", Color("#384838"))
		node.material.set_shader_param("R_MainColor3", Color("#203028"))
		
		node.material.set_shader_param("R_MainColor4", Color("#a0a0a0"))
		node.material.set_shader_param("R_MainColor5", Color("#787878"))
		node.material.set_shader_param("R_MainColor6", Color("#515151"))
		node.material.set_shader_param("R_HairColor", Color("#545454"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#f8b080"))
		node.material.set_shader_param("R_SkinColor2", Color("#b86048"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b3118"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#f8f0d8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#f03000"))
		node.material.set_shader_param("R_CrystalColor3", Color("#a03008"))
		
		node.material.set_shader_param("R_GreenColor1", Color("#48e048"))
		node.material.set_shader_param("R_GreenColor2", Color("#30a030"))
		
		node.material.set_shader_param("R_OutlineColor", Color("#201818"))
		
		node.material.set_shader_param("R_SaberColor0", Color("#f7efd8"))
		node.material.set_shader_param("R_SaberColor1", Color("#e67d7a"))
		node.material.set_shader_param("R_SaberColor2", Color("#e71008"))
		node.material.set_shader_param("R_SaberColor3", Color("#941008"))
		node.material.set_shader_param("R_SaberColor4", Color("#521008"))

func set_saber_colors(node) -> void :
	if rekkyoudan_active:
		if black_zero_armor:
			set_saber_beta_red(node)
		else:
			set_saber_beta_yellow(node)
		if custom_zero_armor:
			customzerocolor()
			displaycolor(node)
	else:
		if black_zero_armor:
			set_saber_beta_purple(node)
		else:
			set_saber_beta_green(node)
		if custom_zero_armor:
			customzerocolor()
			displaycolor(node)

func set_saber_beta_green(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#a0e080"))
		node.material.set_shader_param("R_SaberColor2", Color("#60e040"))
		node.material.set_shader_param("R_SaberColor3", Color("#40c040"))
		node.material.set_shader_param("R_SaberColor4", Color("#42a542"))
		node.material.set_shader_param("R_SaberColor5", Color("#228522"))
func set_saber_beta_yellow(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#e0e080"))
		node.material.set_shader_param("R_SaberColor2", Color("#e0db40"))
		node.material.set_shader_param("R_SaberColor3", Color("#c0ab40"))
		node.material.set_shader_param("R_SaberColor4", Color("#a59542"))
		node.material.set_shader_param("R_SaberColor5", Color("#857522"))
		
func set_saber_beta_purple(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#e0d0e8"))
		node.material.set_shader_param("R_SaberColor2", Color("#c8b0d8"))
		node.material.set_shader_param("R_SaberColor3", Color("#b888d0"))
		node.material.set_shader_param("R_SaberColor4", Color("#a068c0"))
		node.material.set_shader_param("R_SaberColor5", Color("#8048A0"))
func set_saber_beta_red(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#ff5d62"))
		node.material.set_shader_param("R_SaberColor2", Color("#ed0715"))
		node.material.set_shader_param("R_SaberColor3", Color("#bc1819"))
		node.material.set_shader_param("R_SaberColor4", Color("#af0000"))
		node.material.set_shader_param("R_SaberColor5", Color("#8F0000"))

#func set_saber_green(node) -> void :
#	if node != null:
#		node.material.set_shader_param("R_SaberColor0", Color("#e7e7e7"))
#		node.material.set_shader_param("R_SaberColor1", Color("#a0e080"))
#		node.material.set_shader_param("R_SaberColor2", Color("#60e040"))
#		node.material.set_shader_param("R_SaberColor3", Color("#40c040"))
#		node.material.set_shader_param("R_SaberColor4", Color("#42a542"))
#func set_saber_yellow(node) -> void :
#	if node != null:
#		node.material.set_shader_param("R_SaberColor0", Color("#e7e7e7"))
#		node.material.set_shader_param("R_SaberColor1", Color("#e0e080"))
#		node.material.set_shader_param("R_SaberColor2", Color("#e0db40"))
#		node.material.set_shader_param("R_SaberColor3", Color("#c0ab40"))
#		node.material.set_shader_param("R_SaberColor4", Color("#a59542"))
#		
#func set_saber_purple(node) -> void :
#	if node != null:
#		node.material.set_shader_param("R_SaberColor0", Color("#e7e7e7"))
#		node.material.set_shader_param("R_SaberColor1", Color("#e0d0e8"))
#		node.material.set_shader_param("R_SaberColor2", Color("#c8b0d8"))
#		node.material.set_shader_param("R_SaberColor3", Color("#b888d0"))
#		node.material.set_shader_param("R_SaberColor4", Color("#a068c0"))
#func set_saber_red(node) -> void :
#	if node != null:
#		node.material.set_shader_param("R_SaberColor0", Color("#ff9699"))
#		node.material.set_shader_param("R_SaberColor1", Color("#ff5d62"))
#		node.material.set_shader_param("R_SaberColor2", Color("#ed0715"))
#		node.material.set_shader_param("R_SaberColor3", Color("#bc1819"))
#		node.material.set_shader_param("R_SaberColor4", Color("#af0000"))

func set_awakened_effect_green(node) -> void :
	if node != null:
		node.material.set_shader_param("R_AwakenedEffect1", Color("#a0e080"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#60e040"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#40c040"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#42a542"))

func set_awakened_effect_red(node) -> void :
	if node != null:
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))

func set_zeroX8_colors(node) -> void :
	if black_zero_armor:
		set_black_zeroX8_colors(node)
		set_saberX8_purple(node)
		if rekkyoudan_active:
			set_saberX8_red(node)
	else:
		set_zeroX8_normal_colors(node)
		set_saberX8_green(node)
		if rekkyoudan_active:
			set_saberX8_yellow(node)
	if nightshade_zero_armor:
		set_nightshade_zeroX8_colors(node)
	if custom_zero_armor:
		customzerocolor()
		displaycolor(node)
	if awakened_zero_armor:
		pass

func customzerocolor() -> int:
	if Configurations.exists("CustomZeroColor"):
		return Configurations.get("CustomZeroColor")
	return 0

func displaycolor(node) -> void :
	match customzerocolor():
		0:
			set_zeroX8_normal_colors(node)
		1:
			set_black_zeroX8_colors(node)
			set_saberX8_purple(node)
			if rekkyoudan_active:
				set_saberX8_red(node)
		2:
			set_nightmare_zeroX8_colors(node)
		3:
			set_omega_zeroX8_colors(node)
		4:
			set_zero_z_colors(node)
		5:
			set_viral_colors(node)
			set_saberX8_viral(node)
			if rekkyoudan_active:
				set_saberX8_viral_overdrive_alt(node)
		6:
			set_via_colors(node)
		7:
			if black_zero_armor:
				set_new_betazero_black_colors(node)
				set_saber_beta_purple(node)
				if rekkyoudan_active:
					set_saber_beta_red(node)
			else:
				set_new_betazero_normal_colors(node)
				set_saber_beta_green(node)
				if rekkyoudan_active:
					set_saber_beta_yellow(node)
		8:
			set_new_betazero_fake_colors(node)
		9:
			set_custom_zeroX8_colors(node)

func set_zeroX8_normal_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#202020"))
		node.material.set_shader_param("R_AuraColor", Color("#CC1B00"))
		node.material.set_shader_param("R_LightRedColor1", Color("#FF5959"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#f03000"))
		node.material.set_shader_param("R_MainColor2", Color("#a02000"))
		node.material.set_shader_param("R_MainColor3", Color("#602000"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#e0e0e0"))
		node.material.set_shader_param("R_MainColor4", Color("#f0c818"))
		node.material.set_shader_param("R_MainColor5", Color("#b07000"))
		node.material.set_shader_param("R_MainColor6", Color("#6b3118"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#158eff"))
		node.material.set_shader_param("R_CrystalColor3", Color("#0545dc"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#e8ffe9"))
		node.material.set_shader_param("R_ChestColor2", Color("#40e040"))
		node.material.set_shader_param("R_ChestColor3", Color("#20a020"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#f0c818"))
		node.material.set_shader_param("R_ArmorColor2", Color("#b07000"))
		node.material.set_shader_param("R_ArmorColor3", Color("#7c4f00"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#e0e0e0"))
		node.material.set_shader_param("R_GreyColor2", Color("#a0a0a0"))
		node.material.set_shader_param("R_GreyColor3", Color("#606060"))
		node.material.set_shader_param("R_GreyColor4", Color("#444444"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#f8b080"))
		node.material.set_shader_param("R_SkinColor2", Color("#b86048"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b2108"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#e8ffe9"))
		node.material.set_shader_param("R_SaberColor2", Color("#a5e7a5"))
		node.material.set_shader_param("R_SaberColor3", Color("#63e763"))
		node.material.set_shader_param("R_SaberColor4", Color("#42c642"))
		node.material.set_shader_param("R_SaberColor5", Color("#32A632"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#CC1B00"))

func set_black_zeroX8_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#0e111e"))
		node.material.set_shader_param("R_AuraColor", Color("#a068c0"))
		node.material.set_shader_param("R_LightRedColor1", Color("#595959"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#484848"))
		node.material.set_shader_param("R_MainColor2", Color("#303030"))
		node.material.set_shader_param("R_MainColor3", Color("#181818"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#ffffff"))
		node.material.set_shader_param("R_MainColor4", Color("#e0e0e0"))
		node.material.set_shader_param("R_MainColor5", Color("#a0a0a0"))
		node.material.set_shader_param("R_MainColor6", Color("#606060"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#e7e7e7"))
		node.material.set_shader_param("R_CrystalColor2", Color("#28c898"))
		node.material.set_shader_param("R_CrystalColor3", Color("#186868"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#e7e7e7"))
		node.material.set_shader_param("R_ChestColor2", Color("#28c898"))
		node.material.set_shader_param("R_ChestColor3", Color("#186868"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#c8b898"))
		node.material.set_shader_param("R_ArmorColor2", Color("#a88868"))
		node.material.set_shader_param("R_ArmorColor3", Color("#725c47"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#e0e0e0"))
		node.material.set_shader_param("R_GreyColor2", Color("#a0a0a0"))
		node.material.set_shader_param("R_GreyColor3", Color("#606060"))
		node.material.set_shader_param("R_GreyColor4", Color("#444444"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#f8b080"))
		node.material.set_shader_param("R_SkinColor2", Color("#b86048"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b2108"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#c8b0d8"))
		node.material.set_shader_param("R_SaberColor2", Color("#b888d0"))
		node.material.set_shader_param("R_SaberColor3", Color("#a068c0"))
		node.material.set_shader_param("R_SaberColor4", Color("#5F3F72"))
		node.material.set_shader_param("R_SaberColor5", Color("#4F1F62"))

		node.material.set_shader_param("R_AfterimagesColor", Color("#5F3F72"))

func set_nightshade_zeroX8_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#0e111e"))
		node.material.set_shader_param("R_AuraColor", Color("#595959"))
		node.material.set_shader_param("R_LightRedColor1", Color("#595959"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#403838"))
		node.material.set_shader_param("R_MainColor2", Color("#282020"))
		node.material.set_shader_param("R_MainColor3", Color("#181818"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#ffffff"))
		node.material.set_shader_param("R_MainColor4", Color("#e0e0e0"))
		node.material.set_shader_param("R_MainColor5", Color("#a0a0a0"))
		node.material.set_shader_param("R_MainColor6", Color("#606060"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#e7e7e7"))
		node.material.set_shader_param("R_CrystalColor2", Color("#FFD731"))
		node.material.set_shader_param("R_CrystalColor3", Color("#F39428"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#e7e7e7"))
		node.material.set_shader_param("R_ChestColor2", Color("#FFD731"))
		node.material.set_shader_param("R_ChestColor3", Color("#F39428"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#4A57CF"))
		node.material.set_shader_param("R_ArmorColor2", Color("#2A3091"))
		node.material.set_shader_param("R_ArmorColor3", Color("#181C6B"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#e0e0e0"))
		node.material.set_shader_param("R_GreyColor2", Color("#a0a0a0"))
		node.material.set_shader_param("R_GreyColor3", Color("#606060"))
		node.material.set_shader_param("R_GreyColor4", Color("#444444"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#f8b080"))
		node.material.set_shader_param("R_SkinColor2", Color("#b86048"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b2108"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#c8b0d8"))
		node.material.set_shader_param("R_SaberColor2", Color("#b888d0"))
		node.material.set_shader_param("R_SaberColor3", Color("#a068c0"))
		node.material.set_shader_param("R_SaberColor4", Color("#5F3F72"))
		node.material.set_shader_param("R_SaberColor5", Color("#4F1F62"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#5F3F72"))

func set_white_zeroX8_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#0e111e"))
		node.material.set_shader_param("R_AuraColor", Color("#FFFFFF"))
		node.material.set_shader_param("R_LightRedColor1", Color("#ffffff"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#e0e0e0"))
		node.material.set_shader_param("R_MainColor2", Color("#a0a0a0"))
		node.material.set_shader_param("R_MainColor3", Color("#606060"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#595959"))
		node.material.set_shader_param("R_MainColor4", Color("#484848"))
		node.material.set_shader_param("R_MainColor5", Color("#303030"))
		node.material.set_shader_param("R_MainColor6", Color("#181818"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#ff5959"))
		node.material.set_shader_param("R_CrystalColor2", Color("#f03000"))
		node.material.set_shader_param("R_CrystalColor3", Color("#a02000"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#E7A5E7"))
		node.material.set_shader_param("R_ChestColor2", Color("#E763E7"))
		node.material.set_shader_param("R_ChestColor3", Color("#C642C6"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#f0c818"))
		node.material.set_shader_param("R_ArmorColor2", Color("#b07000"))
		node.material.set_shader_param("R_ArmorColor3", Color("#7c4f00"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#f0c818"))
		node.material.set_shader_param("R_GreyColor2", Color("#b07000"))
		node.material.set_shader_param("R_GreyColor3", Color("#7c4f00"))
		node.material.set_shader_param("R_GreyColor4", Color("#472D00"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#F2CAAF"))
		node.material.set_shader_param("R_SkinColor2", Color("#C49385"))
		node.material.set_shader_param("R_SkinColor3", Color("#917163"))
		
		node.material.set_shader_param("R_SaberColor2", Color("#E7A5BB"))
		node.material.set_shader_param("R_SaberColor3", Color("#E7638F"))
		node.material.set_shader_param("R_SaberColor4", Color("#C6426E"))
		node.material.set_shader_param("R_SaberColor4", Color("#a02000"))
		node.material.set_shader_param("R_SaberColor5", Color("#900000"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#a02000"))

func set_nightmare_zeroX8_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#4A086A"))
		node.material.set_shader_param("R_AuraColor", Color("#C56AF6"))
		node.material.set_shader_param("R_LightRedColor1", Color("#C56AF6"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#A0B0C0"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#646A84"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#404060"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#202040"))
		
		node.material.set_shader_param("R_MainColor1", Color("#C56AF6"))
		node.material.set_shader_param("R_MainColor2", Color("#A400D5"))
		node.material.set_shader_param("R_MainColor3", Color("#6A109C"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#F6F6F6"))
		node.material.set_shader_param("R_MainColor4", Color("#F694E6"))
		node.material.set_shader_param("R_MainColor5", Color("#DE4AAC"))
		node.material.set_shader_param("R_MainColor6", Color("#B4007B"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#F6F6F6"))
		node.material.set_shader_param("R_CrystalColor2", Color("#31DB73"))
		node.material.set_shader_param("R_CrystalColor3", Color("#187B29"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#F6F6F6"))
		node.material.set_shader_param("R_ChestColor2", Color("#40E040"))
		node.material.set_shader_param("R_ChestColor3", Color("#20A020"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#F694E6"))
		node.material.set_shader_param("R_ArmorColor2", Color("#DE4AAC"))
		node.material.set_shader_param("R_ArmorColor3", Color("#B4007B"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#F6F6F6"))
		node.material.set_shader_param("R_GreyColor2", Color("#9CB4A4"))
		node.material.set_shader_param("R_GreyColor3", Color("#526A5A"))
		node.material.set_shader_param("R_GreyColor4", Color("#526A5A"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#F694E6"))
		node.material.set_shader_param("R_SkinColor2", Color("#DE4AAC"))
		node.material.set_shader_param("R_SkinColor3", Color("#B4007B"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#F0F0F0"))
		node.material.set_shader_param("R_SaberColor2", Color("#A0B0C0"))
		node.material.set_shader_param("R_SaberColor3", Color("#646A84"))
		node.material.set_shader_param("R_SaberColor4", Color("#404060"))
		node.material.set_shader_param("R_SaberColor5", Color("#102050"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#404060"))

func set_omega_zeroX8_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#381820"))
		node.material.set_shader_param("R_AuraColor", Color("#FF2173"))
		node.material.set_shader_param("R_LightRedColor1", Color("#FF2173"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#FF79FE"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#FF2DD6"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#D700A9"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#B70089"))
		
		node.material.set_shader_param("R_MainColor1", Color("#C82848"))
		node.material.set_shader_param("R_MainColor2", Color("#902040"))
		node.material.set_shader_param("R_MainColor3", Color("#681820"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#F8F0B0"))
		node.material.set_shader_param("R_MainColor4", Color("#D8C868"))
		node.material.set_shader_param("R_MainColor5", Color("#A09850"))
		node.material.set_shader_param("R_MainColor6", Color("#706840"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#E8F8E8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#508078"))
		node.material.set_shader_param("R_CrystalColor3", Color("#286070"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#E8F8E8"))
		node.material.set_shader_param("R_ChestColor2", Color("#508078"))
		node.material.set_shader_param("R_ChestColor3", Color("#286070"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#F8F0B0"))
		node.material.set_shader_param("R_ArmorColor2", Color("#D8C868"))
		node.material.set_shader_param("R_ArmorColor3", Color("#A09850"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#E8F8E8"))
		node.material.set_shader_param("R_GreyColor2", Color("#90B8B8"))
		node.material.set_shader_param("R_GreyColor3", Color("#406070"))
		node.material.set_shader_param("R_GreyColor4", Color("#406070"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#F8D0C0"))
		node.material.set_shader_param("R_SkinColor2", Color("#B88080"))
		node.material.set_shader_param("R_SkinColor3", Color("#685050"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#F7F7F7"))
		node.material.set_shader_param("R_SaberColor2", Color("#FF79FE"))
		node.material.set_shader_param("R_SaberColor3", Color("#FF2DD6"))
		node.material.set_shader_param("R_SaberColor4", Color("#D700A9"))
		node.material.set_shader_param("R_SaberColor5", Color("#C70099"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#D700A9"))

func set_zero_z_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#482860"))
		node.material.set_shader_param("R_AuraColor", Color("#CC1B00"))
		node.material.set_shader_param("R_LightRedColor1", Color("#F8A088"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#F85060"))
		node.material.set_shader_param("R_MainColor2", Color("#D02058"))
		node.material.set_shader_param("R_MainColor3", Color("#981040"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#F8E880"))
		node.material.set_shader_param("R_MainColor4", Color("#F8B800"))
		node.material.set_shader_param("R_MainColor5", Color("#D88010"))
		node.material.set_shader_param("R_MainColor6", Color("#B85020"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#F8F8F8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#90B0D0"))
		node.material.set_shader_param("R_CrystalColor3", Color("#406088"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#F8F8F8"))
		node.material.set_shader_param("R_ChestColor2", Color("#88A838"))
		node.material.set_shader_param("R_ChestColor3", Color("#586828"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#F8E880"))
		node.material.set_shader_param("R_ArmorColor2", Color("#F8B800"))
		node.material.set_shader_param("R_ArmorColor3", Color("#D88010"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#F8F8F8"))
		node.material.set_shader_param("R_GreyColor2", Color("#90B0D0"))
		node.material.set_shader_param("R_GreyColor3", Color("#406088"))
		node.material.set_shader_param("R_GreyColor4", Color("#406088"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#F8D0A8"))
		node.material.set_shader_param("R_SkinColor2", Color("#b88078"))
		node.material.set_shader_param("R_SkinColor3", Color("#685048"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#D0E4D1"))
		node.material.set_shader_param("R_SaberColor2", Color("#94CF94"))
		node.material.set_shader_param("R_SaberColor3", Color("#59CF59"))
		node.material.set_shader_param("R_SaberColor4", Color("#3BB13B"))
		node.material.set_shader_param("R_SaberColor5", Color("#2B912B"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#CC1B00"))

func set_viral_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#202020"))
		node.material.set_shader_param("R_AuraColor", Color("#8a30a4"))
		node.material.set_shader_param("R_LightRedColor1", Color("#8a30a4"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#e0d0e8"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#c8b0d8"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#b888d0"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#a068c0"))
		
		node.material.set_shader_param("R_MainColor1", Color("#8a30a4"))
		node.material.set_shader_param("R_MainColor2", Color("#690079"))
		node.material.set_shader_param("R_MainColor3", Color("#480a55"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#f0f0f2"))
		node.material.set_shader_param("R_MainColor4", Color("#e0c200"))
		node.material.set_shader_param("R_MainColor5", Color("#a06300"))
		node.material.set_shader_param("R_MainColor6", Color("#602400"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#F6F6F6"))
		node.material.set_shader_param("R_CrystalColor2", Color("#ff52ff"))
		node.material.set_shader_param("R_CrystalColor3", Color("#b13475"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#f6f2fc"))
		node.material.set_shader_param("R_ChestColor2", Color("#dbd7e0"))
		node.material.set_shader_param("R_ChestColor3", Color("#c4c1c9"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#e0e0c0"))
		node.material.set_shader_param("R_ArmorColor2", Color("#e0c000"))
		node.material.set_shader_param("R_ArmorColor3", Color("#a06000"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#f0f1f1"))
		node.material.set_shader_param("R_GreyColor2", Color("#9f9f9f"))
		node.material.set_shader_param("R_GreyColor3", Color("#606060"))
		node.material.set_shader_param("R_GreyColor4", Color("#606060"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#202020"))
		node.material.set_shader_param("R_SkinColor2", Color("#202020"))
		node.material.set_shader_param("R_SkinColor3", Color("#202020"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#d8f2d2"))
		node.material.set_shader_param("R_SaberColor2", Color("#25d657"))
		node.material.set_shader_param("R_SaberColor3", Color("#388f2c"))
		node.material.set_shader_param("R_SaberColor4", Color("#40604c"))
		node.material.set_shader_param("R_SaberColor5", Color("#30403c"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#480a55"))

func set_via_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#15184a"))
		node.material.set_shader_param("R_AuraColor", Color("#59bdff"))
		node.material.set_shader_param("R_LightRedColor1", Color("#59bdff"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#9AF6FA"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#52FAFF"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#23E5EB"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#03C5CB"))
		
		node.material.set_shader_param("R_MainColor1", Color("#3d9ddb"))
		node.material.set_shader_param("R_MainColor2", Color("#2085c7"))
		node.material.set_shader_param("R_MainColor3", Color("#0470b8"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#cce9fc"))
		node.material.set_shader_param("R_MainColor4", Color("#bed9eb"))
		node.material.set_shader_param("R_MainColor5", Color("#abc5d6"))
		node.material.set_shader_param("R_MainColor6", Color("#9bb2c2"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#a32c38"))
		node.material.set_shader_param("R_CrystalColor2", Color("#8f1b27"))
		node.material.set_shader_param("R_CrystalColor3", Color("#70000c"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#cce9fc"))
		node.material.set_shader_param("R_ChestColor2", Color("#b3d3e8"))
		node.material.set_shader_param("R_ChestColor3", Color("#a4c6db"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#cce9fc"))
		node.material.set_shader_param("R_ArmorColor2", Color("#bed9eb"))
		node.material.set_shader_param("R_ArmorColor3", Color("#9bb2c2"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#bdccf0"))
		node.material.set_shader_param("R_GreyColor2", Color("#9ba8c7"))
		node.material.set_shader_param("R_GreyColor3", Color("#697287"))
		node.material.set_shader_param("R_GreyColor4", Color("#52596a"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#15184a"))
		node.material.set_shader_param("R_SkinColor2", Color("#15184a"))
		node.material.set_shader_param("R_SkinColor3", Color("#15184a"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#F2FEFF"))
		node.material.set_shader_param("R_SaberColor2", Color("#9AF6FA"))
		node.material.set_shader_param("R_SaberColor3", Color("#52FAFF"))
		node.material.set_shader_param("R_SaberColor4", Color("#23E5EB"))
		node.material.set_shader_param("R_SaberColor5", Color("#13C5DB"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#23E5EB"))

func set_new_betazero_normal_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#202020"))
		node.material.set_shader_param("R_AuraColor", Color("#CC1B00"))
		node.material.set_shader_param("R_LightRedColor1", Color("#FF5959"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#e02000"))
		node.material.set_shader_param("R_MainColor2", Color("#a02000"))
		node.material.set_shader_param("R_MainColor3", Color("#602000"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#E0E0E0"))
		node.material.set_shader_param("R_MainColor4", Color("#E0C000"))
		node.material.set_shader_param("R_MainColor5", Color("#a06000"))
		node.material.set_shader_param("R_MainColor6", Color("#6f4200"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#E0E0E0"))
		node.material.set_shader_param("R_CrystalColor2", Color("#60a0e0"))
		node.material.set_shader_param("R_CrystalColor3", Color("#0040a0"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#E0E0E0"))
		node.material.set_shader_param("R_ChestColor2", Color("#40e040"))
		node.material.set_shader_param("R_ChestColor3", Color("#20a020"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#E0C000"))
		node.material.set_shader_param("R_ArmorColor2", Color("#a06000"))
		node.material.set_shader_param("R_ArmorColor3", Color("#6f4200"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#e0e0e0"))
		node.material.set_shader_param("R_GreyColor2", Color("#a0a0a0"))
		node.material.set_shader_param("R_GreyColor3", Color("#606060"))
		node.material.set_shader_param("R_GreyColor4", Color("#444444"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#E0A080"))
		node.material.set_shader_param("R_SkinColor2", Color("#A06040"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b2400"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#e7e7e7"))
		node.material.set_shader_param("R_SaberColor2", Color("#a0e080"))
		node.material.set_shader_param("R_SaberColor3", Color("#60e040"))
		node.material.set_shader_param("R_SaberColor4", Color("#40c040"))
		node.material.set_shader_param("R_SaberColor5", Color("#42a542"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#CC1B00"))

func set_new_betazero_black_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#0e111e"))
		node.material.set_shader_param("R_AuraColor", Color("#a068c0"))
		node.material.set_shader_param("R_LightRedColor1", Color("#595959"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#484848"))
		node.material.set_shader_param("R_MainColor2", Color("#303030"))
		node.material.set_shader_param("R_MainColor3", Color("#181818"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#f8f8f8"))
		node.material.set_shader_param("R_MainColor4", Color("#c8b898"))
		node.material.set_shader_param("R_MainColor5", Color("#a88868"))
		node.material.set_shader_param("R_MainColor6", Color("#786050"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#60a0e0"))
		node.material.set_shader_param("R_CrystalColor3", Color("#0040a0"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_ChestColor2", Color("#40e040"))
		node.material.set_shader_param("R_ChestColor3", Color("#20a020"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#c8b898"))
		node.material.set_shader_param("R_ArmorColor2", Color("#a88868"))
		node.material.set_shader_param("R_ArmorColor3", Color("#786050"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_GreyColor2", Color("#a0a0a0"))
		node.material.set_shader_param("R_GreyColor3", Color("#606060"))
		node.material.set_shader_param("R_GreyColor4", Color("#444444"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#E0A080"))
		node.material.set_shader_param("R_SkinColor2", Color("#A06040"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b2400"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#e7e7e7"))
		node.material.set_shader_param("R_SaberColor2", Color("#e0d0e8"))
		node.material.set_shader_param("R_SaberColor3", Color("#c8b0d8"))
		node.material.set_shader_param("R_SaberColor4", Color("#b888d0"))
		node.material.set_shader_param("R_SaberColor5", Color("#a068c0"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#a068c0"))

func set_new_betazero_fake_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		
		node.material.set_shader_param("R_OutlineColor", Color("#201818"))
		node.material.set_shader_param("R_AuraColor", Color("#941008"))
		node.material.set_shader_param("R_LightRedColor1", Color("#606860"))
		
		node.material.set_shader_param("R_AwakenedEffect1", Color("#ff5d62"))
		node.material.set_shader_param("R_AwakenedEffect2", Color("#ed0715"))
		node.material.set_shader_param("R_AwakenedEffect3", Color("#bc1819"))
		node.material.set_shader_param("R_AwakenedEffect4", Color("#af0000"))
		
		node.material.set_shader_param("R_MainColor1", Color("#606860"))
		node.material.set_shader_param("R_MainColor2", Color("#384838"))
		node.material.set_shader_param("R_MainColor3", Color("#203028"))
		
		node.material.set_shader_param("R_LightHairColor", Color("#f8f0D8"))
		node.material.set_shader_param("R_MainColor4", Color("#a0a0a0"))
		node.material.set_shader_param("R_MainColor5", Color("#787878"))
		node.material.set_shader_param("R_MainColor6", Color("#515151"))
		
		node.material.set_shader_param("R_CrystalColor1", Color("#f8f0d8"))
		node.material.set_shader_param("R_CrystalColor2", Color("#f03000"))
		node.material.set_shader_param("R_CrystalColor3", Color("#a03008"))
		
		node.material.set_shader_param("R_ChestColor1", Color("#f8f0d8"))
		node.material.set_shader_param("R_ChestColor2", Color("#48e048"))
		node.material.set_shader_param("R_ChestColor3", Color("#30a030"))
		
		node.material.set_shader_param("R_ArmorColor1", Color("#c8b898"))
		node.material.set_shader_param("R_ArmorColor2", Color("#a88868"))
		node.material.set_shader_param("R_ArmorColor3", Color("#786050"))
		
		node.material.set_shader_param("R_GreyColor1", Color("#f8f8f8"))
		node.material.set_shader_param("R_GreyColor2", Color("#a0a0a0"))
		node.material.set_shader_param("R_GreyColor3", Color("#606060"))
		node.material.set_shader_param("R_GreyColor4", Color("#444444"))
		
		node.material.set_shader_param("R_SkinColor1", Color("#f8b080"))
		node.material.set_shader_param("R_SkinColor2", Color("#b86048"))
		node.material.set_shader_param("R_SkinColor3", Color("#6b3118"))
		
		node.material.set_shader_param("R_SaberColor1", Color("#ff5d62"))
		node.material.set_shader_param("R_SaberColor2", Color("#ed0715"))
		node.material.set_shader_param("R_SaberColor3", Color("#8c0000"))
		node.material.set_shader_param("R_SaberColor4", Color("#590000"))
		node.material.set_shader_param("R_SaberColor5", Color("#490000"))
		
		node.material.set_shader_param("R_AfterimagesColor", Color("#490000"))

func set_custom_zeroX8_colors(node) -> void :
	var colors = {
		"R_OutlineColor": "#381820", 
		"R_AuraColor": "#FF2173", 
		"R_LightRedColor1": "#FF2173", 
		
		"R_AwakenedEffect1": "#FF79FE", 
		"R_AwakenedEffect2": "#FF2DD6", 
		"R_AwakenedEffect3": "#E71BB3", 
		"R_AwakenedEffect4": "#D700A9", 
		
		"R_MainColor1": "#C82848", 
		"R_MainColor2": "#902040", 
		"R_MainColor3": "#681820", 
		
		"R_LightHairColor": "#F8F0B0", 
		"R_MainColor4": "#D8C868", 
		"R_MainColor5": "#A09850", 
		"R_MainColor6": "#706840", 
		
		"R_CrystalColor1": "#E8F8E8", 
		"R_CrystalColor2": "#508078", 
		"R_CrystalColor3": "#286070", 
		
		"R_ChestColor1": "#E8F8E8", 
		"R_ChestColor2": "#508078", 
		"R_ChestColor3": "#286070", 
		
		"R_ArmorColor1": "#F8F0B0", 
		"R_ArmorColor2": "#D8C868", 
		"R_ArmorColor3": "#A09850", 
		
		"R_GreyColor1": "#E8F8E8", 
		"R_GreyColor2": "#90B8B8", 
		"R_GreyColor3": "#406070", 
		"R_GreyColor4": "#406070", 
		
		"R_SkinColor1": "#F8D0C0", 
		"R_SkinColor2": "#B88080", 
		"R_SkinColor3": "#685050", 
		
		"R_SaberColor1": "#F7F7F7", 
		"R_SaberColor2": "#FF79FE", 
		"R_SaberColor3": "#FF2DD6", 
		"R_SaberColor4": "#D700A9", 
		"R_SaberColor5": "#C70099", 
		
		"R_AfterimagesColor": "#D700A9", 
	}

	var file = File.new()
	var path = "user://custom_zero_palette.ini"
	if not file.file_exists(path):
		var default_text = \
		"# You can customize Zero\'s colors by changing the hex values below.\n# Format: ParameterName=HexColor\n# Lines starting with \'#\' are comments and ignored.\n\n# Outline color\nOutline_Color=#381820\n\n# Awaken Aura color\nAwaken_Aura_Color=#FF2173\nAwakened_Effect1=#FF79FE\nAwakened_Effect2=#FF2DD6\nAwakened_Effect3=#E71BB3\nAwakened_Effect4=#D700A9\n\n# Light red color\nLight_Red_Color=#FF2173\n\n# Main body colors (light to dark)\nMainBody_Color1=#C82848\nMainBody_Color2=#902040\nMainBody_Color3=#681820\n\n# Hair colors (light to dark)\nHair_Color1=#F8F0B0\nHair_Color2=#D8C868\nHair_Color3=#A09850\nHair_Color4=#706840\n\n# Head crystal colors (light to dark)\nHeadCrystal_Color1=#E8F8E8\nHeadCrystal_Color2=#508078\nHeadCrystal_Color3=#286070\n\n# Chest crystal colors (light to dark)\nChestCrystal_Color1=#E8F8E8\nChestCrystal_Color2=#508078\nChestCrystal_Color3=#286070\n\n# Armor colors (light to dark)\nArmor_Color1=#F8F0B0\nArmor_Color2=#D8C868\nArmor_Color3=#A09850\n\n# Grey parts colors (light to dark)\nGrey_Color1=#E8F8E8\nGrey_Color2=#90B8B8\nGrey_Color3=#406070\nGrey_Color4=#406070\n\n# Skin colors (light to dark)\nSkin_Color1=#F8D0C0\nSkin_Color2=#B88080\nSkin_Color3=#685050\n\n# Saber colors (light to dark)\nSaber_Color1=#F7F7F7\nSaber_Color2=#FF79FE\nSaber_Color3=#FF2DD6\nSaber_Color4=#D700A9\nSaber_Color5=#C70099\n\n# Afterimage effects when dashing\nAfterimages_Color=#D700A9"
		var err = file.open(path, File.WRITE)
		if err == OK:
			file.store_string(default_text)
			file.close()
	
	if file.file_exists(path):
		var err = file.open(path, File.READ)
		if err == OK:
			
			var name_map = {
				"Outline_Color": "R_OutlineColor", 
				"Awaken_Aura_Color": "R_AuraColor", 
				"Light_Red_Color": "R_LightRedColor1", 
				
				"Awakened_Effect1": "R_AwakenedEffect1", 
				"Awakened_Effect2": "R_AwakenedEffect2", 
				"Awakened_Effect3": "R_AwakenedEffect3", 
				"Awakened_Effect4": "R_AwakenedEffect4", 
				
				"MainBody_Color1": "R_MainColor1", 
				"MainBody_Color2": "R_MainColor2", 
				"MainBody_Color3": "R_MainColor3", 
				
				"Hair_Color1": "R_LightHairColor", 
				"Hair_Color2": "R_MainColor4", 
				"Hair_Color3": "R_MainColor5", 
				"Hair_Color4": "R_MainColor6", 
				
				"HeadCrystal_Color1": "R_CrystalColor1", 
				"HeadCrystal_Color2": "R_CrystalColor2", 
				"HeadCrystal_Color3": "R_CrystalColor3", 
				
				"ChestCrystal_Color1": "R_ChestColor1", 
				"ChestCrystal_Color2": "R_ChestColor2", 
				"ChestCrystal_Color3": "R_ChestColor3", 
				
				"Armor_Color1": "R_ArmorColor1", 
				"Armor_Color2": "R_ArmorColor2", 
				"Armor_Color3": "R_ArmorColor3", 
				
				"Grey_Color1": "R_GreyColor1", 
				"Grey_Color2": "R_GreyColor2", 
				"Grey_Color3": "R_GreyColor3", 
				"Grey_Color4": "R_GreyColor4", 
				
				"Skin_Color1": "R_SkinColor1", 
				"Skin_Color2": "R_SkinColor2", 
				"Skin_Color3": "R_SkinColor3", 
				
				"Saber_Color1": "R_SaberColor1", 
				"Saber_Color2": "R_SaberColor2", 
				"Saber_Color3": "R_SaberColor3", 
				"Saber_Color4": "R_SaberColor4",
				"Saber_Color5": "R_SaberColor5",
				
				"Afterimages_Color": "R_AfterimagesColor",
			}
			
			while not file.eof_reached():
				var line = file.get_line().strip_edges()
				if line == "" or line.begins_with("#"):
					continue
				var parts = line.split("=")
				if parts.size() != 2:
					continue
				var name = parts[0]
				var hex_color = parts[1]
				
				if name_map.has(name):
					var shader_param = name_map[name]
					var color = Color(hex_color)
					node.material.set_shader_param(shader_param, color)
			file.close()

func set_custom_axl_colors(node) -> void :
	var colors = {
		"R_AxlOutlineColor": "#2A005C", 
		
		"R_AxlMainColor1": "#C56AF6",
		"R_AxlMainColor2": "#A400D5",
		"R_AxlMainColor3": "#7A009F",
		
		"R_AxlMainColor4": "#A0B0C0",
		"R_AxlMainColor5": "#646A84",
		"R_AxlMainColor6": "#404060",
		
		"R_AxlGleyColor1": "#D5E2EF",
		"R_AxlGleyColor2": "#A2C1E0",
		
		"R_AxlCrystalColor1": "#D5E2EF",
		"R_AxlCrystalColor2": "#31DB73",
		"R_AxlCrystalColor3": "#187B29",
		
		"R_AxlHairColor1": "#F694E6",
		"R_AxlHairColor2": "#DE4AAC",
		"R_AxlHairColor3": "#B4007B",
		
		"R_AxlYellowColor1": "#DE4AAC",
		"R_AxlYellowColor2": "#B4007B",
		
		"R_AxlRedColor1": "#CD3299",
		"R_AxlRedColor2": "#9D006B",
		
		"R_AxlFlameColor1": "#F694E6",
		"R_AxlFlameColor2": "#DE4AAC",
		"R_AxlFlameColor3": "#B4007B",
		
		"R_AxlSkinColor1": "#F694E6", 
		"R_AxlSkinColor2": "#DE4AAC", 
		"R_AxlSkinColor3": "#B4007B", 
		
		"R_AxlAfterimagesColor1": "#A0B0C0", 
		"R_AxlAfterimagesColor2": "#102050", 
	}
	var file = File.new()
	var path = "user://custom_axl_palette.ini"
	if not file.file_exists(path):
		var default_text = \
		"# You can customize Axl\'s colors by changing the hex values below.\n# Format: ParameterName=HexColor\n# Lines starting with \'#\' are comments and ignored.\n\n# Outline color\nAxl_Outline_Color=#2A005C\n\n# Main body colors (light to dark)\nAxl_Main_Color1=#C56AF6\nAxl_Main_Color2=#A400D5\nAxl_Main_Color3=#7A009F\n\nAxl_Main_Color4=#A0B0C0\nAxl_Main_Color5=#646A84\nAxl_Main_Color6=#404060\n\n# Gley colors (will glow)\nAxl_Gley_Color1=#D5E2EF\nAxl_Gley_Color2=#A2C1E0\n\n# Crystal colors (will glow)\nAxl_Crystal_Color1=#D5E2EF\nAxl_Crystal_Color2=#31DB73\nAxl_Crystal_Color3=#187B29\n\n# Hair colors (light to dark)\nAxl_Hair_Color1=#F694E6\nAxl_Hair_Color2=#DE4AAC\nAxl_Hair_Color3=#B4007B\n\n# Yellow colors\nAxl_Yellow_Color1=#DE4AAC\nAxl_Yellow_Color2=#B4007B\n\n# Red colors\nAxl_Red_Color1=#CD3299\nAxl_Red_Color2=#9D006B\n\n# Flame colors(some weapon)\nAxl_Flame_Color1=#F694E6\nAxl_Flame_Color2=#DE4AAC\nAxl_Flame_Color3=#B4007B\n\n# Skin colors\nAxl_Skin_Color1=#F694E6\nAxl_Skin_Color2=#DE4AAC\nAxl_Skin_Color3=#B4007B\n\n# Afterimages colors\nAxl_Afterimages_Color1=#A0B0C0\nAxl_Afterimages_Color2=#102050"
		var err = file.open(path, File.WRITE)
		if err == OK:
			file.store_string(default_text)
			file.close()
	
	if file.file_exists(path):
		var err = file.open(path, File.READ)
		if err == OK:
			
			var name_map = {
				"Axl_Outline_Color": "R_AxlOutlineColor", 
				
				"Axl_Main_Color1": "R_AxlMainColor1",
				"Axl_Main_Color2": "R_AxlMainColor2",
				"Axl_Main_Color3": "R_AxlMainColor3",
				
				"Axl_Main_Color4": "R_AxlMainColor4",
				"Axl_Main_Color5": "R_AxlMainColor5",
				"Axl_Main_Color6": "R_AxlMainColor6",
				
				"Axl_Gley_Color1": "R_AxlGleyColor1",
				"Axl_Gley_Color2": "R_AxlGleyColor2",
				
				"Axl_Crystal_Color1": "R_AxlCrystalColor1",
				"Axl_Crystal_Color2": "R_AxlCrystalColor2",
				"Axl_Crystal_Color3": "R_AxlCrystalColor3",
				
				"Axl_Hair_Color1": "R_AxlHairColor1",
				"Axl_Hair_Color2": "R_AxlHairColor2",
				"Axl_Hair_Color3": "R_AxlHairColor3",
		
				"Axl_Yellow_Color1": "R_AxlYellowColor1",
				"Axl_Yellow_Color2": "R_AxlYellowColor2",
		
				"Axl_Red_Color1": "R_AxlRedColor1",
				"Axl_Red_Color2": "R_AxlRedColor2",
		
				"Axl_Flame_Color1": "R_AxlFlameColor1",
				"Axl_Flame_Color2": "R_AxlFlameColor2",
				"Axl_Flame_Color3": "R_AxlFlameColor3",
				
				"Axl_Skin_Color1": "R_AxlSkinColor1", 
				"Axl_Skin_Color2": "R_AxlSkinColor2", 
				"Axl_Skin_Color3": "R_AxlSkinColor3", 
				
				"Axl_Afterimages_Color1": "R_AxlAfterimagesColor1",
				"Axl_Afterimages_Color2": "R_AxlAfterimagesColor2",
			}
			
			while not file.eof_reached():
				var line = file.get_line().strip_edges()
				if line == "" or line.begins_with("#"):
					continue
				var parts = line.split("=")
				if parts.size() != 2:
					continue
				var name = parts[0]
				var hex_color = parts[1]
				
				if name_map.has(name):
					var shader_param = name_map[name]
					var color = Color(hex_color)
					node.material.set_shader_param(shader_param, color)
			file.close()

func set_saberX8_colors(node) -> void :
	if CharacterManager.player_character == "Zero":
		if rekkyoudan_active:
			set_saberX8_yellow(node)
			if black_zero_armor:
				set_saberX8_red(node)
			if custom_zero_armor:
				customzerocolor()
				displaycolor(node)
			if awakened_zero_armor:
				pass
		else:
			set_saberX8_green(node)
			if black_zero_armor:
				set_saberX8_purple(node)
			if custom_zero_armor:
				customzerocolor()
				displaycolor(node)
			if awakened_zero_armor:
				pass

func set_saberX8_green(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#e8ffe9"))
		node.material.set_shader_param("R_SaberColor2", Color("#a5e7a5"))
		node.material.set_shader_param("R_SaberColor3", Color("#63e763"))
		node.material.set_shader_param("R_SaberColor4", Color("#42c642"))
		node.material.set_shader_param("R_SaberColor5", Color("#32A632"))
func set_saberX8_yellow(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#ffffff"))
		node.material.set_shader_param("R_SaberColor2", Color("#ffff6f"))
		node.material.set_shader_param("R_SaberColor3", Color("#ffaf3f"))
		node.material.set_shader_param("R_SaberColor4", Color("#bf6d2a"))
		node.material.set_shader_param("R_SaberColor5", Color("#Af4d1a"))
func set_saberX8_purple(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#c8b0d8"))
		node.material.set_shader_param("R_SaberColor2", Color("#b888d0"))
		node.material.set_shader_param("R_SaberColor3", Color("#a068c0"))
		node.material.set_shader_param("R_SaberColor4", Color("#5F3F72"))
		node.material.set_shader_param("R_SaberColor5", Color("#4F1F62"))
func set_saberX8_red(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#ff5d62"))
		node.material.set_shader_param("R_SaberColor2", Color("#ed0715"))
		node.material.set_shader_param("R_SaberColor3", Color("#8c0000"))
		node.material.set_shader_param("R_SaberColor4", Color("#590000"))
		node.material.set_shader_param("R_SaberColor5", Color("#490000"))
func set_saberX8_aqua(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#F2FEFF"))
		node.material.set_shader_param("R_SaberColor2", Color("#9AF6FA"))
		node.material.set_shader_param("R_SaberColor3", Color("#52FAFF"))
		node.material.set_shader_param("R_SaberColor4", Color("#23E5EB"))
		node.material.set_shader_param("R_SaberColor5", Color("#13C5DB"))
func set_saberX8_blue(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#5B6CFF"))
		node.material.set_shader_param("R_SaberColor2", Color("#4A57CF"))
		node.material.set_shader_param("R_SaberColor3", Color("#2A3091"))
		node.material.set_shader_param("R_SaberColor4", Color("#181C6B"))
		node.material.set_shader_param("R_SaberColor5", Color("#08005B"))
func set_saberX8_pink(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#FFE8FE"))
		node.material.set_shader_param("R_SaberColor2", Color("#E7A5E7"))
		node.material.set_shader_param("R_SaberColor3", Color("#E763E7"))
		node.material.set_shader_param("R_SaberColor4", Color("#C642C6"))
		node.material.set_shader_param("R_SaberColor5", Color("#B622B6"))
func set_saber_omega_pink(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#F7F7F7"))
		node.material.set_shader_param("R_SaberColor2", Color("#FF79FE"))
		node.material.set_shader_param("R_SaberColor3", Color("#FF2DD6"))
		node.material.set_shader_param("R_SaberColor4", Color("#D700A9"))
		node.material.set_shader_param("R_SaberColor5", Color("#C70099"))
func set_saberX8_rose(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#FFE8EF"))
		node.material.set_shader_param("R_SaberColor2", Color("#E7A5BB"))
		node.material.set_shader_param("R_SaberColor3", Color("#E7638F"))
		node.material.set_shader_param("R_SaberColor4", Color("#C6426E"))
		node.material.set_shader_param("R_SaberColor5", Color("#B6225E"))

func set_saberX8_viral(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#d8f2d2"))
		node.material.set_shader_param("R_SaberColor2", Color("#25d657"))
		node.material.set_shader_param("R_SaberColor3", Color("#388f2c"))
		node.material.set_shader_param("R_SaberColor4", Color("#40604c"))
		node.material.set_shader_param("R_SaberColor5", Color("#30403c"))

func set_saberX8_viral_overdrive_alt(node) -> void :
	if node != null:
		node.material.set_shader_param("R_SaberColor1", Color("#e3d0d9"))
		node.material.set_shader_param("R_SaberColor2", Color("#f45455"))
		node.material.set_shader_param("R_SaberColor3", Color("#c80b21"))
		node.material.set_shader_param("R_SaberColor4", Color("#753753"))
		node.material.set_shader_param("R_SaberColor5", Color("#651743"))

func set_layer_colors(node) -> void :
	set_layer_saber_green(node)
	if rekkyoudan_active:
		set_layer_saber_yellow(node)

func set_layer_saber_green(node) -> void :
	if node != null:
		node.material.set_shader_param("R_LSaberColor1", Color("#e8ffe9"))
		node.material.set_shader_param("R_LSaberColor2", Color("#a5e7a5"))
		node.material.set_shader_param("R_LSaberColor3", Color("#63e763"))
		node.material.set_shader_param("R_LSaberColor4", Color("#42c642"))
		node.material.set_shader_param("R_LSaberColor5", Color("#32A632"))

func set_layer_saber_yellow(node) -> void :
	if node != null:
		node.material.set_shader_param("R_LSaberColor1", Color("#ffffff"))
		node.material.set_shader_param("R_LSaberColor2", Color("#ffff6f"))
		node.material.set_shader_param("R_LSaberColor3", Color("#ffaf3f"))
		node.material.set_shader_param("R_LSaberColor4", Color("#bf6d2a"))
		node.material.set_shader_param("R_LSaberColor5", Color("#Af4d1a"))

func check_for_deactivated_skills_Zero() -> void :
	remove_deactivated_skills_Zero()
	if "tenshouha_deactivated" in GameManager.collectibles:
		tenshouha_active = false
	if "juuhazan_deactivated" in GameManager.collectibles:
		juuhazan_active = false
	if "rasetsusen_deactivated" in GameManager.collectibles:
		rasetsusen_active = false
	if "raikousen_deactivated" in GameManager.collectibles:
		raikousen_active = false
	if "youdantotsu_deactivated" in GameManager.collectibles:
		youdantotsu_active = false
	if "rekkyoudan_deactivated" in GameManager.collectibles or not "trilobyte_weapon" in GameManager.collectibles:
		rekkyoudan_active = false
	if "hyouryuushou_deactivated" in GameManager.collectibles:
		hyouryuushou_active = false
	if "enkoujin_deactivated" in GameManager.collectibles:
		enkoujin_active = false

func remove_deactivated_skills_Zero() -> void :
	GameManager.remove_collectible_from_savedata("tenshouha_deactivated")
	GameManager.remove_collectible_from_savedata("juuhazan_deactivated")
	GameManager.remove_collectible_from_savedata("rasetsusen_deactivated")
	GameManager.remove_collectible_from_savedata("raikousen_deactivated")
	GameManager.remove_collectible_from_savedata("youdantotsu_deactivated")
	GameManager.remove_collectible_from_savedata("rekkyoudan_deactivated")
	GameManager.remove_collectible_from_savedata("hyouryuushou_deactivated")
	GameManager.remove_collectible_from_savedata("enkoujin_deactivated")



func print_frame_sizes(_sprite):
	if _sprite != null:
		var sprite_frames = _sprite.frames
		var animation_name = _sprite.animation
		var frame_count = sprite_frames.get_frame_count(animation_name)
		
		for i in range(frame_count):
			var frame_texture = sprite_frames.get_frame(animation_name, i)
			var frame_size = frame_texture.get_size()
			
			
			return frame_size

func update_texture(texture: Texture, reference_tex: SpriteFrames):
	var reference_frames: SpriteFrames = reference_tex
	var updated_frames = SpriteFrames.new()
	for animation in reference_frames.get_animation_names():
		if animation != "default":
			updated_frames.add_animation(animation)
			updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
			updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
			for i in reference_frames.get_frame_count(animation):
				var updated_texture: AtlasTexture = reference_frames.get_frame(animation, i).duplicate()
				updated_texture.atlas = texture
				updated_frames.add_frame(animation, updated_texture)
	updated_frames.remove_animation("default")
	return updated_frames

func update_texture_with_new_size(texture: Texture, reference_tex: SpriteFrames):
	var reference_frames: SpriteFrames = reference_tex
	var updated_frames = SpriteFrames.new()
	
	var new_texture_size = texture.get_size()
	var first_frame_texture: AtlasTexture = reference_frames.get_frame("idle", 0)
	var old_texture_size = first_frame_texture.atlas.get_size()
	var width_scale = new_texture_size.x / old_texture_size.x
	var height_scale = new_texture_size.y / old_texture_size.y
	
	for animation in reference_frames.get_animation_names():
		if animation != "default":
			updated_frames.add_animation(animation)
			updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
			updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
			
			for i in reference_frames.get_frame_count(animation):
				var old_texture: AtlasTexture = reference_frames.get_frame(animation, i)
				var updated_texture: AtlasTexture = old_texture.duplicate()
				updated_texture.atlas = texture
				
				var old_region = old_texture.region
				var new_region = Rect2(
					old_region.position * Vector2(width_scale, height_scale), 
					old_region.size * Vector2(width_scale, height_scale)
				)
				updated_texture.region = new_region
				updated_frames.add_frame(animation, updated_texture)
			
	updated_frames.remove_animation("default")
	return updated_frames

func update_texture_animations(texture: Texture, reference_tex: SpriteFrames, animations_to_replace: Array) -> SpriteFrames:
	var reference_frames: SpriteFrames = reference_tex
	var updated_frames = SpriteFrames.new()
	
	var new_texture_size = texture.get_size()
	var first_frame_texture: AtlasTexture = reference_frames.get_frame("idle", 0)
	var old_texture_size = first_frame_texture.atlas.get_size()
	var width_scale = new_texture_size.x / old_texture_size.x
	var height_scale = new_texture_size.y / old_texture_size.y
	
	for animation in reference_frames.get_animation_names():
		if animation in animations_to_replace:
			updated_frames.add_animation(animation)
			updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
			updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
			
			for i in range(reference_frames.get_frame_count(animation)):
				var old_texture: AtlasTexture = reference_frames.get_frame(animation, i)
				var updated_texture: AtlasTexture = old_texture.duplicate()
				updated_texture.atlas = texture
				
				var old_region = old_texture.region
				var new_region = Rect2(
					old_region.position * Vector2(width_scale, height_scale), 
					old_region.size * Vector2(width_scale, height_scale)
				)
				updated_texture.region = new_region
				updated_frames.add_frame(animation, updated_texture)
			
	return updated_frames

func update_texture_specific_animations(texture: Texture, reference_tex: SpriteFrames, animations_to_update: Array):
	var reference_frames: SpriteFrames = reference_tex
	var updated_frames = SpriteFrames.new()
	
	var frames_per_row = 13
	
	for animation in reference_frames.get_animation_names():
		updated_frames.add_animation(animation)
		updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
		updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
		
		if animation in animations_to_update:
			
			for i in range(reference_frames.get_frame_count(animation)):
				var updated_texture: AtlasTexture = reference_frames.get_frame(animation, i).duplicate()
				updated_texture.atlas = texture
				updated_frames.add_frame(animation, updated_texture)
				
				var x_index = i % frames_per_row
				var y_index = i / frames_per_row
				
		else:
			for i in range(reference_frames.get_frame_count(animation)):
				updated_frames.add_frame(animation, reference_frames.get_frame(animation, i))
	return updated_frames

func get_texture_animation(texture: Texture, reference_tex: SpriteFrames, animations_to_update: Array) -> SpriteFrames:
	var reference_frames: SpriteFrames = reference_tex
	var updated_frames = SpriteFrames.new()
	var frames_per_row = 13
	for animation in reference_frames.get_animation_names():
		updated_frames.add_animation(animation)
		updated_frames.set_animation_speed(animation, reference_frames.get_animation_speed(animation))
		updated_frames.set_animation_loop(animation, reference_frames.get_animation_loop(animation))
		
		if animation in animations_to_update:
			for i in range(reference_frames.get_frame_count(animation)):
				var atlas_texture: AtlasTexture = reference_frames.get_frame(animation, i)
				
				if atlas_texture is AtlasTexture:
					var region = atlas_texture.region
					var frame_x = int(region.position.x / region.size.x)
					var frame_y = int(region.position.y / region.size.y)
					
				var updated_texture: AtlasTexture = atlas_texture.duplicate()
				updated_texture.atlas = texture
				updated_frames.add_frame(animation, updated_texture)
		else:
			for i in range(reference_frames.get_frame_count(animation)):
				updated_frames.add_frame(animation, reference_frames.get_frame(animation, i))
	return updated_frames
	

func process_res_file(input_res_path: String, new_texture_path: String, output_res_path: String, animations_to_skip: Array):
	var sprite_frames = load(input_res_path) as SpriteFrames
	if not sprite_frames:
		return

	var new_texture = load(new_texture_path) as Texture
	if not new_texture:
		return
	
	for animation_name in sprite_frames.get_animation_names():
		if animation_name in animations_to_skip:
			continue
		for i in range(sprite_frames.get_frame_count(animation_name)):
			var frame_texture = sprite_frames.get_frame(animation_name, i)
			if frame_texture is AtlasTexture:
				var atlas_texture = frame_texture as AtlasTexture
				var updated_texture = atlas_texture.duplicate() as AtlasTexture
				updated_texture.atlas = new_texture
				updated_texture.region = atlas_texture.region
				var original_position = atlas_texture.region.position
				var new_position = updated_texture.region.position
				sprite_frames.set_frame(animation_name, i, updated_texture)
	var result = ResourceSaver.save(output_res_path, sprite_frames)


func process_res_file_include(input_res_path: String, new_texture_path: String, output_res_path: String, animations_to_include: Array):
	var sprite_frames = load(input_res_path) as SpriteFrames
	if not sprite_frames:
		return

	var new_texture = load(new_texture_path) as Texture
	if not new_texture:
		return

	for animation_name in sprite_frames.get_animation_names():
		var should_replace = animation_name in animations_to_include
		for i in range(sprite_frames.get_frame_count(animation_name)):
			var frame_texture = sprite_frames.get_frame(animation_name, i)
			if frame_texture is AtlasTexture:
				var old_atlas = frame_texture as AtlasTexture
				var new_atlas = AtlasTexture.new()
				if should_replace:
					new_atlas.atlas = new_texture
				else:
					new_atlas.atlas = old_atlas.atlas
				new_atlas.region = old_atlas.region
				new_atlas.margin = old_atlas.margin
				new_atlas.filter_clip = old_atlas.filter_clip
				sprite_frames.set_frame(animation_name, i, new_atlas)
	var result = ResourceSaver.save(output_res_path, sprite_frames)



func _set_correct_dialogues(dialog_starter, dialogue) -> Resource:
	var _dialog = dialogue
	if dialog_starter == "StartCutscene":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue.tres")
			
	if dialog_starter == "INTRO_1":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_2.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_2.tres")
	if dialog_starter == "INTRO_2":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_3.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_3.tres")
	if dialog_starter == "INTRO_3":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_4.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_4.tres")
	if dialog_starter == "INTRO_4":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_5.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Intro_Dialogue_5.tres")

	if dialog_starter == "Antonion":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Antonion_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Antonion_Dialogue.tres")
	if dialog_starter == "Manowar":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Manowar_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Manowar_Dialogue.tres")
	if dialog_starter == "Mantis":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Mantis_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Mantis_Dialogue.tres")
	if dialog_starter == "Panda":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Panda_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Panda_Dialogue.tres")
	if dialog_starter == "Rooster":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Rooster_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Rooster_Dialogue.tres")
	if dialog_starter == "Sunflower":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Sunflower_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Sunflower_Dialogue.tres")
	if dialog_starter == "Trilobyte":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Trilobyte_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Trilobyte_Dialogue.tres")
	if dialog_starter == "Yeti":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Yeti_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Yeti_Dialogue.tres")
	
	if dialog_starter == "Vile Booster Forest":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Vile_miniboss_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Vile_miniboss_Dialogue.tres")
	if dialog_starter == "Vile Primrose":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Vile_antonion_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Vile_antonion_Dialogue.tres")
	if dialog_starter == "Vile":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Vile_jakob_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Vile_jakob_Dialogue.tres")
	if dialog_starter == "Vile Final" or dialog_starter == "DevilBear":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Vile_final_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Vile_final_Dialogue.tres")
	if dialog_starter == "Vile Awaken" or dialog_starter == "DevilBearUP":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/ExtraVileZero.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/ExtraVileAxl.tres")
	
	if dialog_starter == "CopySigma":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/CopySigma_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/CopySigma_Dialogue.tres")
			
	if dialog_starter == "Sigma":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Sigma_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Sigma_Dialogue.tres")
			
	if dialog_starter == "Lumine":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Lumine_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Lumine_Dialogue.tres")
			
			
	if dialog_starter == "Secret1":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Secret3_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Secret3_Dialogue.tres")
	if dialog_starter == "Secret1Defeated":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Secret3_Def_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Secret3_Def_Dialogue.tres")
			
	if dialog_starter == "Secret2":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Secret2_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Secret2_Dialogue.tres")
	if dialog_starter == "Secret2Defeated":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/DialogSystem/Dialogs/Stages/Secret2_Def_Dialogue.tres")
		if player_character == "Axl":
			_dialog = load("res://Axl_mod/DialogSystem/Dialogs/Stages/Secret2_Def_Dialogue.tres")

	if dialog_starter == "Zero_Boss":
		if player_character == "Zero":
			_dialog = load("res://Zero_mod/Boss/Dialogue/AwakenedZero_Dialogue_Zero.tres")
		if player_character == "Axl":
			_dialog = load("res://Zero_mod/Boss/Dialogue/AwakenedZero_Dialogue_Axl.tres")


	return _dialog
