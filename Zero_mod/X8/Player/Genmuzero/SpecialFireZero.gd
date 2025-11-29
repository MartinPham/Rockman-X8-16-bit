extends Shot

onready var special_pistol: Node2D = get_node_or_null("Genmuzero")

var _special_active: bool = false
var is_executing_special: bool = false
var execute_genmu_zero: bool = false

func _ready() -> void :
	Event.listen("weapon_select_left", self, "activate_different_alternates")
	Event.listen("weapon_select_right", self, "activate_different_alternates")
	Event.listen("weapon_select_buster", self, "activate_different_alternates")
	#Event.listen("select_weapon", self, "activate_different_alternates")
	activate_different_alternates()

func _physics_process(_delta: float) -> void :
	activate_different_alternates()

func activate_different_alternates() -> void :
	special_pistol.active = true
	set_current_weapon(special_pistol)
	_special_active = true

func _Setup() -> void :
	current_weapon.fire(0)

func _StartCondition() -> bool:
	if _special_active:
		if current_weapon and character.has_control():
			if special_pistol.current_ammo >= current_weapon.ammo_per_shot:
				return true
		return false
	else:
		return false

func deactivate_all_specials() -> void :
	for child in get_children():
		child.active = false
	_special_active = false
