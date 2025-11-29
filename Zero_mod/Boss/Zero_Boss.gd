extends Panda

onready var dmg_sfx: AudioStreamPlayer = $damage

func _ready() -> void :
	Event.connect("player_death", self, "false_all")
	var sprite = get_node("animatedSprite")
	var effect_sprite = sprite.get_node("effectSprite")
	CharacterManager.set_zeroX8_normal_colors(sprite)
	CharacterManager.set_saberX8_green(sprite)
	if CharacterManager.player_character == "X":
		CharacterManager.set_zeroX8_normal_colors(sprite)
		CharacterManager.set_saberX8_green(sprite)
		CharacterManager.only_x = true
		CharacterManager.only_zero = false
		CharacterManager.only_axl = false
		
	elif CharacterManager.player_character == "Zero":
		CharacterManager.set_omega_zeroX8_colors(sprite)
		CharacterManager.set_saber_omega_pink(sprite)
		CharacterManager.only_x = false
		CharacterManager.only_zero = true
		CharacterManager.only_axl = false

	elif CharacterManager.player_character == "Axl":
		CharacterManager.set_new_betazero_fake_colors(sprite)
		CharacterManager.set_saberX8_red(sprite)
		CharacterManager.only_x = false
		CharacterManager.only_zero = false
		CharacterManager.only_axl = true
	
	else:
		CharacterManager.set_zeroX8_normal_colors(sprite)
		CharacterManager.set_saberX8_green(sprite)
		CharacterManager.only_x = true
		CharacterManager.only_zero = false
		CharacterManager.only_axl = false

func false_all() -> void :
	CharacterManager.only_x = false
	CharacterManager.only_zero = false
	CharacterManager.only_axl = false

func _on_DamageReflector_shield_broken() -> void :
	if not is_executing("Desperation"):
		damage.invulnerability_time = damage.weakness_invulnerability_time
		damage.emit_signal("charged_weakness_hit", - get_facing_direction())
		damage.max_flash_time = damage.invulnerability_time
		reduce_health(10)
		dmg_sfx.play()
