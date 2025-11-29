extends Node2D

export  var active: bool = false

onready var mubarrier: AnimatedSprite = $"../animatedSprite/mu_barrier"
onready var character = get_parent()
onready var on_sound = $mubarrieron
onready var off_sound: = $mubarrieroff

var allow_summon_barrier: bool = true

func _Update(delta: float) -> void :
	._Update(delta)
	var rotate_speed = (delta * 12)
	mubarrier.rotate(rotate_speed)

func _ready() -> void :
	if active:
		deactivate()
		allow_summon_barrier = true
		character.listen("zero_health", self, "deactivate")
		Event.connect("player_death", self, "deactivate")
		Event.listen("character_switch", self, "deactivate")
		Event.listen("character_switch_end", self, "check")
		Event.listen("weapon_select_left", self, "check")
		Event.listen("weapon_select_right", self, "check")
		Event.listen("select_weapon_zero", self, "check")
		Event.connect("pause_menu_closed", self, "check")
		Event.listen("weapon_select_buster", self, "check")
		Event.listen("ridearmor_activate", self, "deactivate")
		Event.listen("ridearmor_deactivate", self, "check")
		#Event.listen("damage", self, "deactivate2")
		character.listen("damage", self, "deactivate2")
		character.listen("weapon_selected", self, "check")

func check() -> void :
	if CharacterManager.player_character == "Zero":
		if character.saber_node.current_weapon.name != "Rogue-Blade":
			deactivate()
		else:
			activate()

func activate() -> void :
	if allow_summon_barrier:
		if not active:
			active = true
			mubarrier.show()
			on_sound.play()
			allow_summon_barrier = false
			if CharacterManager.player_character == "Zero":
				if is_instance_valid(GameManager.player):
					var zero = GameManager.player
					zero.equip_mu_barrier_parts()

func deactivate() -> void :
	if active:
		active = false
		mubarrier.hide()
		allow_summon_barrier = true
		if CharacterManager.player_character == "Zero":
			if is_instance_valid(GameManager.player):
				var zero = GameManager.player
				zero.cancel_mu_barrier_parts()

func deactivate2(damage_value: float, inflicter: Object) -> void :
	if active:
		active = false
		mubarrier.hide()
		off_sound.play()
		Event.emit_signal("call_mu_barrier")
		if CharacterManager.player_character == "Zero":
			if is_instance_valid(GameManager.player):
				var zero = GameManager.player
				zero.cancel_mu_barrier_parts()
		Tools.timer(4.0, "reset", self)
		Tools.timer(4.0, "check", self)

func reset() -> void :
	allow_summon_barrier = true

