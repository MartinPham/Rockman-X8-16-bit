extends SaberZeroX8Wall

onready var hanger_sound: AudioStreamPlayer = $hanger

func hitbox_and_position() -> void :
	hitbox_damage = damage
	hitbox_damage_boss = damage_boss
	hitbox_damage_weakness = damage_weakness
	if character.saber_node.current_weapon.name == "K-Knuckle":
		if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2(0, - 20)
			hitbox_downright = Vector2(35, 17)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
	if character.saber_node.current_weapon.name == "V-Hanger":
		if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2(0, - 20)
			hitbox_downright = Vector2(75, 17)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

func should_add_saber_combo() -> bool:
	return false

func set_saber_animations():
	animatedSprite.animation = "saber_slide"
	animatedSprite.frame = 0
	if character.saber_node.current_weapon.name == "K-Knuckle":
		saber_sound.play()
	elif character.saber_node.current_weapon.name == "V-Hanger":
		hanger_sound.play()
	else:
		saber_sound.play()
