extends ZeroBlocking
class_name ExtraZeroBlocking

onready var extra_armor_limit: = $"../../Limits/Extra_Zero_Limit"
onready var extra_blocking_wall: CollisionShape2D = $extracollisionShape2D

func _ready() -> void :
	if active:
		on_block_event()
		Event.connect("pitch_black_energized", self, "unlock_event")

func on_block_event() -> void :
	extra_armor_limit.disabled = true
	extra_blocking_wall.set_deferred("disabled", false)

func unlock_event() -> void :
	extra_armor_limit.disabled = false
	extra_blocking_wall.set_deferred("disabled", true)
