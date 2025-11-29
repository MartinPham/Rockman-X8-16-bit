extends Node
class_name BlackZeroBlocking

export  var active: bool = false
export  var difficulty_minumum: int = 0
export  var need_all_weapons: bool = true
export  var need_all_zero_weapons: bool = false
export  var collectible: String = ""
export  var block_if_collected: bool = true

onready var black_armor_limit: = $"../../Limits/Black_Zero_Limit"
onready var black_blocking_wall: CollisionShape2D = $blackcollisionShape2D

var black_unlocked: bool = true

func _ready() -> void :
	if active:
		Event.listen("damage", self, "on_block_event")
		call_deferred("black_block_wall")

func black_block_wall() -> void :
	if block_if_collected:
		if collectible != "":
			if collectible in GameManager.collectibles:
				black_unlocked = false
	
	if need_all_weapons and not got_all_boss_weapons():
		black_unlocked = false
	
	if need_all_zero_weapons and not got_all_zero_weapons():
		black_unlocked = false
	
	if CharacterManager.game_mode < difficulty_minumum:
		black_unlocked = true

	black_blocking_wall.disabled = black_unlocked
	black_armor_limit.disabled = not black_unlocked

func on_block_event() -> void :
	black_armor_limit.disabled = true
	black_blocking_wall.set_deferred("disabled", false)

func unlock_event() -> void :
	black_armor_limit.disabled = false
	black_blocking_wall.set_deferred("disabled", true)

func got_all_boss_weapons() -> bool:
	var unlocked_weapons = 0
	for item in GameManager.collectibles:
		if "_weapon" in item and not "boss_weapon" in item:
			unlocked_weapons += 1
	if unlocked_weapons >= 8:
		return true
	return false

func got_all_zero_weapons() -> bool:
	var unlocked_weapons = 0
	for item in GameManager.collectibles:
		if "_zero" in item and not "seen_zero" in item:
			unlocked_weapons += 1
			
	if unlocked_weapons >= 5:
		return true
	return false
