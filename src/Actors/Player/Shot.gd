extends Ability
class_name Shot

export  var normal_sprites: SpriteFrames
export  var arm_pointing_sprites: SpriteFrames
export  var default_arm_point_duration: float = 0.3
export  var infinite_regular_ammo: bool = false
export  var infinite_charged_ammo: bool = false

var next_shot_ready: bool = false
var arm_point_dur: float = 0.0
var disabled_layer: bool = false
var weapons: Array = []
var current_weapon

var can_auto_charge: bool = false

func _ready() -> void :
	if active:
		update_list_of_weapons()
		set_buster_as_weapon()
		Event.listen("shot_layer_disabled", self, "on_shot_layer_disabled")
		Event.listen("shot_layer_enabled", self, "on_shot_layer_enabled")
		Event.listen("ridearmor_deactivate", self, "check")
		Event.listen("character_switch", self, "check")
		check()

func check() -> void :
	can_auto_charge = true
	yield(get_tree().create_timer(0.1), "timeout")
	if CharacterManager.player_character == "X" or CharacterManager.player_character == "Alia":
		if CharacterManager.auto_charge and not GameManager.player.is_executing("Ride"):
			if not character.get_action_pressed("auto_charge"):
				Input.action_press("auto_charge")

func _StartCondition() -> bool:
	if current_weapon:
		return current_weapon.has_ammo()
	return false

func _Setup() -> void :
	next_shot_ready = false
	fire(current_weapon)

func _EndCondition() -> bool:
	return not character.is_executing("Forced") and not Input.is_action_just_pressed(actions[0]) and Has_time_ran_out()

func Has_time_ran_out() -> bool:
	if arm_point_dur != 0:
		return arm_point_dur < timer
	else:
		return default_arm_point_duration < timer

func _Interrupt() -> void :
	disable_animation_layer()

func got_hit() -> bool:
	for each in character.executing_moves:
		if each.name == "Damage":
			return true
	return false

var press_timer: = 0.0

func increase_keep_press_timer(_delta: float) -> void :
	press_timer += _delta

func _Update(_delta: float) -> void :
	increase_keep_press_timer(_delta)
	if got_hit():
		return
	if action_just_pressed() and not is_initial_frame():
		if _StartCondition():
			fire(current_weapon)

	if CharacterManager.rapid_fire:
		if character.get_action_pressed("alt_fire"):
			Input.action_release("alt_fire")
			yield(get_tree().create_timer(0.001), "timeout")
			Input.action_press("alt_fire")
	#	if character.get_action_pressed("fire"):
	#		Input.action_release("fire")
	#		yield(get_tree().create_timer(0.001), "timeout")
	#		Input.action_press("fire")
	if GameManager.player.is_executing("Ride"):
		can_auto_charge = false
	if not GameManager.player.is_executing("Ride"):
		if CharacterManager.player_character == "X" or CharacterManager.player_character == "Alia":
			if CharacterManager.auto_charge and can_auto_charge:
				if character.get_action_pressed("fire"):
					Input.action_release("auto_charge")
				if not character.get_action_pressed("auto_charge"):
					Input.action_press("auto_charge")

func update_list_of_weapons() -> void :
	weapons.clear()
	for child in get_children():
		if child is Weapon or child is BossWeapon:
			if child.active:
				weapons.append(child)

func set_buster_as_weapon() -> void :
	next_shot_ready = false
	for weapon in weapons:
		if "Buster" in weapon.name and weapon.active:
			set_current_weapon(weapon)
			break

func set_current_weapon(weapon) -> void :
	next_shot_ready = false
	current_weapon = weapon

func has_infinite_regular_ammo() -> bool:
	return infinite_regular_ammo

func has_infinite_charged_ammo() -> bool:
	return infinite_charged_ammo

func play_animation_on_initialize() -> void :
	enable_animation_layer()

func enable_animation_layer() -> void :
	character.set_animation_layer(arm_pointing_sprites)
	Event.emit_signal("shot_layer_enabled")
	disabled_layer = false

func fire(weapon) -> void :
	enable_animation_layer()
	restart_animation()
	weapon.fire(0)
	timer = 0.0

func restart_animation() -> void :
	if character.get_animation() == "recover":
		character.animatedSprite.set_frame(1)

func action_pressed() -> bool:
	for input in actions:
		if character.get_action_pressed(input):
			return true
	return false

func action_just_pressed() -> bool:
	for input in actions:
		if character.get_action_just_pressed(input):
			return true
	return false

func on_shot_layer_disabled() -> void :
	disabled_layer = true

func on_shot_layer_enabled() -> void :
	disabled_layer = false
	timer = 0.0

func disable_animation_layer() -> void :
	if not disabled_layer:
		character.set_animation_layer(normal_sprites)
		Event.emit_signal("shot_layer_disabled")
