extends ZeroBlocking
class_name UltimateXBlocking

onready var armor_limit: = $"../../Limits/Ultimate_X_Limit"
onready var ultimate_blocking_wall: CollisionShape2D = $ultimatecollisionShape2D

var x_armors: Array = [
	"hermes_head", 
	"hermes_arms", 
	"hermes_body", 
	"hermes_legs", 
	"icarus_head", 
	"icarus_arms", 
	"icarus_body", 
	"icarus_legs", 
	]

func _ready() -> void :
	#unlock_event()
	on_block_event()
	unblock_wall()

func unblock_wall() -> void :
	if "axl_first_time" in GameManager.collectibles and "axl_second_time" in GameManager.collectibles:
		unlock_event()
	if (check_for_x_armors()):
		unlock_event()

func check_for_x_armors() -> bool:
	var total_items = 0.0
	var collected_items = 0.0
	for item in x_armors:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	return false

func on_block_event() -> void :
	armor_limit.disabled = true
	ultimate_blocking_wall.set_deferred("disabled", false)

func unlock_event() -> void :
	armor_limit.disabled = false
	ultimate_blocking_wall.set_deferred("disabled", true)
