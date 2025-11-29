extends ZeroBlocking
class_name FloppaAxlBlocking

onready var floppa_armor_limit: = $"../../Limits/Floppa_Axl_Limit"
onready var floppa_blocking_wall: CollisionShape2D = $extracollisionShape2D

func _ready() -> void :
	if active:
		on_block_event()
		if "axl_first_time" in GameManager.collectibles and "axl_second_time" in GameManager.collectibles:
			unlock_event()
		if "black_zero_armor" in GameManager.collectibles and "ultimate_x_armor" in GameManager.collectibles and "white_axl_armor" in GameManager.collectibles:
			unlock_event()

func on_block_event() -> void :
	floppa_armor_limit.disabled = true
	floppa_blocking_wall.set_deferred("disabled", false)

func unlock_event() -> void :
	floppa_armor_limit.disabled = false
	floppa_blocking_wall.set_deferred("disabled", true)
