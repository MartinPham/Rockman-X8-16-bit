extends Weapon

const minimum_time_between_recharges: float = 0.2

export  var recharge_rate: float = 1.0
export  var weapon: Resource

onready var parent: = get_parent()
onready var animatedsprite: AnimatedSprite = $"../../animatedSprite"
onready var weapon_stasis: Node2D = $"../../WeaponStasis"
onready var jump_damage: Node2D = $"../../JumpDamage"
onready var vfx: AnimatedSprite = $break_vfx


var timer: float = 0.0
var last_time_hit: float = 0.0

var vfx_casted: bool = false
var ready_time_casted: bool = false
var first_time_casted: bool = false
var can_use: bool = false

func _ready() -> void :
	character.listen("equipped_armor", self, "on_equip")
	character.listen("zero_health", self, "on_zero_health")
	Event.listen("hit_enemy", self, "recharge")
	Event.listen("enemy_kill", self, "recharge")
	on_equip()

func ready_time():
	if CharacterManager.awakened_zero_armor and not CharacterManager.awakened_zero_full_power_max:
		if not ready_time_casted:
			reduce_ammo(ammo_per_shot)
			ready_time_casted = true
	else:
		ready_time_casted = true

func recharge(_d = null) -> void :
	if CharacterManager.awakened_zero_armor:
		if active and current_ammo < max_ammo:
			if timer > last_time_hit + minimum_time_between_recharges:
				last_time_hit = timer
				current_ammo = clamp(current_ammo + 0.0, 0.0, max_ammo)
	elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
		if active and current_ammo < max_ammo:
			if timer > last_time_hit + minimum_time_between_recharges:
				last_time_hit = timer
				current_ammo = clamp(current_ammo + 1.5, 0.0, max_ammo)
	else:
		if active and current_ammo < max_ammo:
			if timer > last_time_hit + minimum_time_between_recharges:
				last_time_hit = timer
				current_ammo = clamp(current_ammo + 1.0, 0.0, max_ammo)


func on_equip():
	active = true
	current_ammo = max_ammo
	Event.emit_signal("special_activated", self, character)
	parent.update_list_of_weapons()
	set_physics_process(active)
	ready_time_casted = false
	first_time_casted = false
	ready_time()

func _input(event: InputEvent) -> void :
	if active and has_ammo() and character.has_control():
		if event.is_action_pressed("select_special") and not event.is_action_pressed("move_down"):
			fire()

func fire(_charge_level: = 0) -> void :
	if active and has_ammo() and character.has_control():
		reduce_ammo(0.001)
		vfx.show()
		character.execute_genmu_zero = true
		Input.action_press("select_special")

func has_ammo() -> bool:
	return current_ammo >= max_ammo

func has_ammo_5() -> bool:
	return current_ammo >= 5

func has_ammo_10() -> bool:
	return current_ammo >= 10

func has_ammo_20() -> bool:
	return current_ammo >= 20

func has_ammo_30() -> bool:
	return current_ammo >= 30

func has_ammo_59() -> bool:
	return current_ammo >= 59

func can_shoot() -> bool:
	return has_ammo()

func reduce_ammo(expent):
	current_ammo -= expent

func on_zero_health() -> void :
	animatedsprite.modulate = Color.white

func _physics_process(delta: float) -> void :
	timer += delta
	if CharacterManager.awakened_zero_armor:
		if not first_time_casted:
			if current_ammo < max_ammo:
				current_ammo = clamp(current_ammo + delta * 0.5, 0.0, max_ammo)
		if first_time_casted:
			if current_ammo < max_ammo:
				current_ammo = clamp(current_ammo + delta * 10.0, 0.0, max_ammo)
		if CharacterManager.awakened_zero_full_power_max:
			if current_ammo < max_ammo:
				current_ammo = clamp(current_ammo + delta * 120.0, 0.0, max_ammo)
	else:
		if current_ammo < max_ammo:
			current_ammo = clamp(current_ammo + delta * 0.5, 0.0, max_ammo)

	if has_ammo() and not vfx_casted:
		vfx.frame = 0
		vfx_casted = true
			
	elif not has_ammo() and vfx_casted:
		vfx_casted = false
		
	if vfx_casted:
		if CharacterManager.awakened_zero_armor:
			Tools.timer(1.0, "hide", self)
		if not first_time_casted:
			first_time_casted = true
	
	if CharacterManager.awakened_zero_armor and CharacterManager.awakened_zero_full_power_max:
		vfx.hide()

func hide() -> void :
	vfx.hide()
