extends SaberBaseZeroX8
class_name SaberComboZeroX8


onready var swordwave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/swordwave.tscn")
onready var zbuster: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/zbuster.tscn")
onready var shingetsurin: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/shingetsurin.tscn")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
var creator: Node2D

onready var saber2_sound: AudioStreamPlayer = $saber2
onready var saber3_sound: AudioStreamPlayer = $saber3
onready var bfan_sound: AudioStreamPlayer = $bfan
onready var bfan2_sound: AudioStreamPlayer = $bfan2
onready var bfan3_sound: AudioStreamPlayer = $bfan3
onready var dglaive_sound: AudioStreamPlayer = $dglaive
onready var dglaive2_sound: AudioStreamPlayer = $dglaive2
onready var dglaive3_sound: AudioStreamPlayer = $dglaive3
onready var dglaive4_sound: AudioStreamPlayer = $dglaive4
onready var breaker_sound: AudioStreamPlayer = $breaker
onready var zbuster_sound: AudioStreamPlayer = $zbuster
onready var swordwave_sound: AudioStreamPlayer = $swordwave
onready var shingetsurin_sound: AudioStreamPlayer = $shingetsurin
onready var rogueslash_sound: AudioStreamPlayer = $rogueslash
onready var rogueslash2_sound: AudioStreamPlayer = $rogueslash2
onready var rogueslash3_sound: AudioStreamPlayer = $rogueslash3
onready var rogueslash4_sound: AudioStreamPlayer = $rogueslash4
onready var hanger_sound: AudioStreamPlayer = $hanger
onready var hanger2_sound: AudioStreamPlayer = $hanger2
onready var sigmablade_sound: AudioStreamPlayer = $sigmablade
onready var sigmablade2_sound: AudioStreamPlayer = $sigmablade2
onready var sigmablade3_sound: AudioStreamPlayer = $sigmablade3


var input_buffer: Array = []
var buffer_window_threshold: int = 3


func hitbox_and_position():
	if animatedSprite.animation == "saber_1":
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_damage = damage
			hitbox_damage_boss = damage_boss
			hitbox_damage_weakness = damage_weakness
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 5, - 42)
				hitbox_downright = Vector2(72, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "B-Fan":
			hitbox_damage = damage
			hitbox_damage_boss = damage_boss
			hitbox_damage_weakness = damage_weakness
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 5, - 42)
				hitbox_downright = Vector2(72, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(35, - 42)
				hitbox_downright = Vector2(72, 34)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "D-Glaive":
			hitbox_damage = damage
			hitbox_damage_boss = damage_boss
			hitbox_damage_weakness = damage_weakness
			hitbox_rehit_time = 0.05
			hitbox_break_guards = false
			if animatedSprite.frame >= 0 and animatedSprite.frame < 1:
				hitbox_upleft = Vector2( - 100, - 60)
				hitbox_downright = Vector2( - 65, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 65, - 80)
				hitbox_downright = Vector2( - 35, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 1 and animatedSprite.frame < 2:
				hitbox_upleft = Vector2( - 35, - 103)
				hitbox_downright = Vector2(59, - 75)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2(29, - 75)
				hitbox_downright = Vector2(59, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 2 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(59, - 75)
				hitbox_downright = Vector2(127, 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "T-Breaker":
			hitbox_damage = damage
			hitbox_damage_boss = damage_boss
			hitbox_damage_weakness = damage_weakness
			hitbox_rehit_time = 0.1
			hitbox_break_guards = true
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 5, - 68)
				hitbox_downright = Vector2(75, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(35, - 48)
				hitbox_downright = Vector2(90, 38)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Rogue-Blade":
			hitbox_damage = damage
			hitbox_damage_boss = damage_boss
			hitbox_damage_weakness = damage_weakness
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 1 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 45, - 42)
				hitbox_downright = Vector2(85, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "V-Hanger":
			hitbox_damage = 8
			hitbox_damage_boss = 4
			hitbox_damage_weakness = 24
			hitbox_break_guards = true
			hitbox_rehit_time = 0.15
			if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 20)
				hitbox_downright = Vector2(62, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Sigma-Blade":
			hitbox_damage = 6
			hitbox_damage_boss = 10
			hitbox_damage_weakness = 20
			hitbox_rehit_time = 0.05
			hitbox_break_guards = true
			if animatedSprite.frame >= 0 and animatedSprite.frame < 2:
				hitbox_upleft = Vector2( - 105, - 60)
				hitbox_downright = Vector2( - 65, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 60, - 90)
				hitbox_downright = Vector2( 0, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 0, - 103)
				hitbox_downright = Vector2(115, - 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(55, - 80)
				hitbox_downright = Vector2(140, 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(45, - 0)
				hitbox_downright = Vector2(120, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)


	if animatedSprite.animation == "saber_2":
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_damage = 4
			hitbox_damage_boss = 6
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 5, - 20)
				hitbox_downright = Vector2(65, 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 50, - 30)
				hitbox_downright = Vector2(55, - 4)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "B-Fan":
			hitbox_damage = 4
			hitbox_damage_boss = 6
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 5, - 30)
				hitbox_downright = Vector2(65, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 60, - 50)
				hitbox_downright = Vector2(55, 6)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "D-Glaive":
			hitbox_damage = 4
			hitbox_damage_boss = 6
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.05
			hitbox_break_guards = false
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 5, - 20)
				hitbox_downright = Vector2(93, 17)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 105, - 40)
				hitbox_downright = Vector2(0, - 15)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Rogue-Blade":
			hitbox_damage = 4
			hitbox_damage_boss = 6
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 1 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 5, - 20)
				hitbox_downright = Vector2(85, 15)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 75, - 40)
				hitbox_downright = Vector2(85, 15)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "V-Hanger":
			hitbox_damage = 8
			hitbox_damage_boss = 4
			hitbox_damage_weakness = 24
			hitbox_break_guards = true
			hitbox_rehit_time = 0.15
			if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 20)
				hitbox_downright = Vector2(62, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Sigma-Blade":
			hitbox_damage = 8
			hitbox_damage_boss = 12
			hitbox_damage_weakness = 48
			hitbox_rehit_time = 0.05
			hitbox_break_guards = true
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( 0, - 20)
				hitbox_downright = Vector2(115, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 110, - 60)
				hitbox_downright = Vector2(115, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2( - 110, - 60)
				hitbox_downright = Vector2(- 20, - 25)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_3":
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_damage = 12
			hitbox_damage_boss = 8
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.2
			hitbox_break_guards = true
			if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 59)
				hitbox_downright = Vector2(73, 21)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Z-Breaker":
			if not CharacterManager.extra_saber_combo:
				hitbox_damage = 12
				hitbox_damage_boss = 8
				hitbox_damage_weakness = 24
				hitbox_rehit_time = 0.2
				hitbox_break_guards = true
				if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
					hitbox_upleft = Vector2( - 25, - 34)
					hitbox_downright = Vector2(18, - 15)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
				if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
					hitbox_upleft = Vector2( - 5, - 39)
					hitbox_downright = Vector2(68, 21)
					spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "B-Fan":
			hitbox_damage = 12
			hitbox_damage_boss = 8
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.2
			hitbox_break_guards = true
			if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 70)
				hitbox_downright = Vector2(73, 21)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "D-Glaive":
			hitbox_damage = 12
			hitbox_damage_boss = 8
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = true
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 72, 44)
				hitbox_downright = Vector2(50, 74)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(50, 24)
				hitbox_downright = Vector2(110, 74)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(85, - 32)
				hitbox_downright = Vector2(133, 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(55, - 52)
				hitbox_downright = Vector2(118, - 32)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2(35, - 112)
				hitbox_downright = Vector2(98, - 52)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Rogue-Blade":
			hitbox_damage = 12
			hitbox_damage_boss = 8
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.2
			hitbox_break_guards = true
			if animatedSprite.frame >= 1 and animatedSprite.frame <3:
				hitbox_upleft = Vector2(-20, - 80)
				hitbox_downright = Vector2(0, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2(0, - 80)
				hitbox_downright = Vector2(85, 25)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "V-Hanger":
			hitbox_damage = 8
			hitbox_damage_boss = 4
			hitbox_damage_weakness = 24
			hitbox_break_guards = true
			hitbox_rehit_time = 0.15
			if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 20)
				hitbox_downright = Vector2(62, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Sigma-Blade":
			hitbox_damage = 24
			hitbox_damage_boss = 16
			hitbox_damage_weakness = 48
			hitbox_rehit_time = 0.1
			hitbox_break_guards = true
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 100, 30)
				hitbox_downright = Vector2(0, 85)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(0, 0)
				hitbox_downright = Vector2(90, 77)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 4 and animatedSprite.frame < 5:
				hitbox_upleft = Vector2(30, - 35)
				hitbox_downright = Vector2(115, 55)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 5 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2(25, - 115)
				hitbox_downright = Vector2(105, - 35)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2(25, - 115)
				hitbox_downright = Vector2(45, - 30)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_4":
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_damage = 15
			hitbox_damage_boss = 10
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = true
			if animatedSprite.frame >= 3 and animatedSprite.frame < 7:
				if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
					hitbox_upleft = Vector2( - 25, - 62)
					hitbox_downright = Vector2(7, 15)
				if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
					hitbox_upleft = Vector2( - 55, - 79)
					hitbox_downright = Vector2(63, - 20)
				if animatedSprite.frame >= 5 and animatedSprite.frame < 7:
					hitbox_upleft = Vector2( - 5, - 79)
					hitbox_downright = Vector2(78, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Z-Breaker":
			hitbox_damage = damage
			hitbox_damage_boss = damage_boss
			hitbox_damage_weakness = damage_weakness
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 5, - 42)
				hitbox_downright = Vector2(72, 14)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "V-Hanger":
			hitbox_damage = 8
			hitbox_damage_boss = 4
			hitbox_damage_weakness = 24
			hitbox_break_guards = true
			hitbox_rehit_time = 0.15
			if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 20)
				hitbox_downright = Vector2(62, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "D-Glaive":
			hitbox_damage = 10
			hitbox_damage_boss = 5
			hitbox_damage_weakness = 20
			hitbox_break_guards = true
			hitbox_rehit_time = 0.0375
			if animatedSprite.frame >= 0 and animatedSprite.frame < 12:
				hitbox_upleft = Vector2( - 100, - 70)
				hitbox_downright = Vector2(105, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Rogue-Blade":
			hitbox_damage = 15
			hitbox_damage_boss = 10
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = true
			if animatedSprite.frame >= 1 and animatedSprite.frame <3:
				hitbox_upleft = Vector2(-20, - 80)
				hitbox_downright = Vector2(0, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2(0, - 80)
				hitbox_downright = Vector2(85, 25)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 8 and animatedSprite.frame < 17:
				if animatedSprite.frame >= 8 and animatedSprite.frame < 10:
					hitbox_upleft = Vector2( - 65, - 65)
					hitbox_downright = Vector2(7, 15)
				if animatedSprite.frame >= 10 and animatedSprite.frame < 14:
					hitbox_upleft = Vector2( - 55, - 85)
					hitbox_downright = Vector2(67, - 20)
				if animatedSprite.frame >= 14 and animatedSprite.frame < 17:
					hitbox_upleft = Vector2( - 5, - 120)
					hitbox_downright = Vector2(160, 45)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				if animatedSprite.frame < 10:
					Event.emit_signal("screenshake", 1.0)

	if animatedSprite.animation == "saber_5":
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_damage = 15
			hitbox_damage_boss = 10
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = true
			if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2( - 25, - 60)
				hitbox_downright = Vector2(35, - 15)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2( - 5, - 50)
				hitbox_downright = Vector2(85, 50)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "Z-Braeker":
			hitbox_damage = 4
			hitbox_damage_boss = 6
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = false
			if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2( - 5, - 20)
				hitbox_downright = Vector2(65, 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 50, - 30)
				hitbox_downright = Vector2(55, - 4)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		elif character.saber_node.current_weapon.name == "V-Hanger":
			hitbox_damage = 16
			hitbox_damage_boss = 8
			hitbox_damage_weakness = 24
			hitbox_break_guards = true
			hitbox_rehit_time = 0.15
			if animatedSprite.frame >= 2 and animatedSprite.frame < 9:
				hitbox_upleft = Vector2(0, - 20)
				hitbox_downright = Vector2(62, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_6":
		if character.saber_node.current_weapon.name == "Saber":
			hitbox_damage = 12
			hitbox_damage_boss = 8
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.1
			hitbox_break_guards = true
			if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 70)
				hitbox_downright = Vector2(80, 35)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				
		elif character.saber_node.current_weapon.name == "Z-Breaker":
			hitbox_damage = 12
			hitbox_damage_boss = 8
			hitbox_damage_weakness = 24
			hitbox_rehit_time = 0.2
			hitbox_break_guards = true
			if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2(0, - 59)
				hitbox_downright = Vector2(73, 21)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_dash":
		if character.saber_node.current_weapon.name == "Z-Breaker":
			if not CharacterManager.extra_saber_combo:
				hitbox_damage = 12
				hitbox_damage_boss = 8
				hitbox_damage_weakness = 24
				hitbox_rehit_time = 0.2
				hitbox_break_guards = true
				if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
					hitbox_upleft = Vector2( - 25, - 34)
					hitbox_downright = Vector2(18, - 15)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
				if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
					hitbox_upleft = Vector2( - 5, - 39)
					hitbox_downright = Vector2(68, 21)
					spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_dash2":
		if character.saber_node.current_weapon.name == "Z-Breaker":
			if not CharacterManager.extra_saber_combo:
				hitbox_damage = 12
				hitbox_damage_boss = 8
				hitbox_damage_weakness = 24
				hitbox_rehit_time = 0.2
				hitbox_break_guards = true
				if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
					hitbox_upleft = Vector2( - 25, - 34)
					hitbox_downright = Vector2(18, - 15)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
				if animatedSprite.frame >= 3 and animatedSprite.frame < 6:
					hitbox_upleft = Vector2( - 5, - 39)
					hitbox_downright = Vector2(68, 21)
					spawn_hitbox(hitbox_upleft, hitbox_downright)

	reset_hitbox()

func end_saber_state():
	return ending_saber_state

func is_in_buffer_window() -> bool:
	if animatedSprite.animation == "saber_1" and animatedSprite.frame >= 7 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_2" and animatedSprite.frame >= 7 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_3" and animatedSprite.frame >= 7 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_4" and animatedSprite.frame >= 7 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_5" and animatedSprite.frame >= 7 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_shot_normal" and animatedSprite.frame >= 11 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_shot_fast1" and animatedSprite.frame >= 7 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_shot_fast2" and animatedSprite.frame >= 7 - buffer_window_threshold:
		return true
	return false

func should_add_saber_combo():
	if character.saber_node.current_weapon.name == "T-Breaker":
		return false
	if animatedSprite.animation == "saber_1":
		return animatedSprite.frame >= 7
	if animatedSprite.animation == "saber_2":
		return animatedSprite.frame >= 7
	if animatedSprite.animation == "saber_3":
		if CharacterManager.player_character == "Zero":
			if character.saber_node.current_weapon.name == "V-Hanger":
				return animatedSprite.frame >= 7
		else:
			return false
	if animatedSprite.animation == "saber_4":
		if CharacterManager.player_character == "Zero":
			if character.saber_node.current_weapon.name == "V-Hanger":
				return animatedSprite.frame >= 7
		else:
			return false
	if animatedSprite.animation == "saber_shot_normal":
		return animatedSprite.frame >= 11
	if animatedSprite.animation == "saber_shot_fast1":
		return animatedSprite.frame >= 7
	if animatedSprite.animation == "saber_shot_fast2":
		return animatedSprite.frame >= 7
	return false

func should_add_saber_extra_combo():
	if animatedSprite.animation == "saber_shot_normal":
		return animatedSprite.frame >= 11
	if character.saber_node.current_weapon.name == "T-Breaker":
		return false
	if animatedSprite.animation == "saber_1":
		return animatedSprite.frame >= 7
	if animatedSprite.animation == "saber_2":
		return animatedSprite.frame >= 7
	if animatedSprite.animation == "saber_3":
		if CharacterManager.player_character == "Zero":
			if character.saber_node.current_weapon.name == "Saber":
				return animatedSprite.frame >= 8
			elif character.saber_node.current_weapon.name == "V-Hanger":
					return animatedSprite.frame >= 7
			elif character.saber_node.current_weapon.name == "D-Glaive":
					return animatedSprite.frame >= 7
			elif character.saber_node.current_weapon.name == "Z-Breaker" and character.get_action_pressed("move_down"):
				return animatedSprite.frame >= 10
			elif character.saber_node.current_weapon.name == "Rogue-Blade" and character.get_action_pressed("move_down"):
				return animatedSprite.frame >= 7
		else:
			return false
	if animatedSprite.animation == "saber_4":
		if CharacterManager.player_character == "Zero":
			if character.saber_node.current_weapon.name == "Saber":
				return animatedSprite.frame >= 9
			elif character.saber_node.current_weapon.name == "V-Hanger":
				return animatedSprite.frame >= 7
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				return animatedSprite.frame >= 7
		else:
			return false
	if animatedSprite.animation == "saber_5":
		if CharacterManager.player_character == "Zero":
			if character.saber_node.current_weapon.name == "Saber" and character.get_action_pressed("move_up"):
				return animatedSprite.frame >= 11
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				return animatedSprite.frame >= 7
		else:
			return false
	return false

func set_saber_animations():
	if character.is_on_floor():
		if slashes == 0:
			animatedSprite.animation = "saber_1"
			if character.saber_node.current_weapon.name == "Saber":
				saber_sound.play()
			elif character.saber_node.current_weapon.name == "B-Fan":
				bfan_sound.play()
			elif character.saber_node.current_weapon.name == "D-Glaive":
				dglaive_sound.play()
			elif character.saber_node.current_weapon.name == "T-Breaker":
				breaker_sound.play()
			elif character.saber_node.current_weapon.name == "Rogue-Blade":
				rogueslash_sound.play()
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			elif character.saber_node.current_weapon.name == "Sigma-Blade":
				sigmablade_sound.play()
				
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				if CharacterManager.extra_saber_combo and not character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_shot_normal"
				if not CharacterManager.extra_saber_combo and not character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_shot_normal"
				if not CharacterManager.extra_saber_combo and character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_shot_fast1"
				if CharacterManager.awakened_zero_armor:
					shingetsurin_sound.play()
					create_shingetsurin(global_position, 10)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					zbuster_sound.play()
					create_zbuster(global_position, 3.6)
				else:
					zbuster_sound.play()
					create_zbuster(global_position, 3)
				
			else:
				saber_sound.play()
		if slashes == 1:
			animatedSprite.animation = "saber_2"
			if character.saber_node.current_weapon.name == "Saber":
				saber2_sound.play()
			elif character.saber_node.current_weapon.name == "B-Fan":
				bfan2_sound.play()
			elif character.saber_node.current_weapon.name == "D-Glaive":
				dglaive2_sound.play()
			elif character.saber_node.current_weapon.name == "Rogue-Blade":
				rogueslash2_sound.play()
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			elif character.saber_node.current_weapon.name == "Sigma-Blade":
				sigmablade2_sound.play()
				
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				if not CharacterManager.extra_saber_combo and not character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_shot_normal"
				if not CharacterManager.extra_saber_combo and character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_shot_fast2"
				if CharacterManager.awakened_zero_armor:
					shingetsurin_sound.play()
					create_shingetsurin(global_position, 10)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					zbuster_sound.play()
					create_zbuster(global_position, 3.6)
				else:
					zbuster_sound.play()
					create_zbuster(global_position, 3)
				
			else:
				saber2_sound.play()
		if slashes == 2:
			animatedSprite.animation = "saber_3"
			if character.saber_node.current_weapon.name == "Saber":
				saber3_sound.play()
			elif character.saber_node.current_weapon.name == "B-Fan":
				bfan3_sound.play()
			elif character.saber_node.current_weapon.name == "D-Glaive":
				dglaive3_sound.play()
			elif character.saber_node.current_weapon.name == "Rogue-Blade":
				rogueslash3_sound.play()
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			elif character.saber_node.current_weapon.name == "Sigma-Blade":
				sigmablade3_sound.play()
				
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				if not CharacterManager.extra_saber_combo and not character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_dash"
				if  not CharacterManager.extra_saber_combo and character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_dash2"
				swordwave_sound.play()
				if CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 20)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 12)
				else:
					create_swordwave(global_position, 10)
				
			else:
				saber3_sound.play()
		if slashes == 3:
			animatedSprite.animation = "saber_4"
			if character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			else:
				saber2_sound.play()
		if slashes == 4:
			animatedSprite.animation = "saber_5"
			if character.saber_node.current_weapon.name == "V-Hanger":
				hanger2_sound.play()
			else:
				saber3_sound.play()
	slashes += 1

func set_saber_extra_animations():
	if character.is_on_floor():
		if slashes == 0:
			animatedSprite.animation = "saber_1"
			if character.saber_node.current_weapon.name == "Saber":
				saber_sound.play()
			elif character.saber_node.current_weapon.name == "B-Fan":
				bfan_sound.play()
			elif character.saber_node.current_weapon.name == "D-Glaive":
				dglaive_sound.play()
			elif character.saber_node.current_weapon.name == "T-Breaker":
				breaker_sound.play()

			elif character.saber_node.current_weapon.name == "Z-Breaker":
				if CharacterManager.extra_saber_combo and not character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_shot_normal"
				if CharacterManager.extra_saber_combo and character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_1"
				if CharacterManager.awakened_zero_armor:
					shingetsurin_sound.play()
					create_shingetsurin(global_position, 10)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					zbuster_sound.play()
					create_zbuster(global_position, 3.6)
				else:
					zbuster_sound.play()
					create_zbuster(global_position, 3)

			elif character.saber_node.current_weapon.name == "Rogue-Blade":
				rogueslash_sound.play()
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			elif character.saber_node.current_weapon.name == "Sigma-Blade":
				sigmablade_sound.play()
			else:
				saber_sound.play()
		if slashes == 1:
			animatedSprite.animation = "saber_2"
			if character.saber_node.current_weapon.name == "Saber":
				saber2_sound.play()
			elif character.saber_node.current_weapon.name == "B-Fan":
				bfan2_sound.play()
			elif character.saber_node.current_weapon.name == "D-Glaive":
				dglaive2_sound.play()
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				if CharacterManager.extra_saber_combo and not character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_shot_normal"
				if CharacterManager.extra_saber_combo and character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_2"
				if CharacterManager.awakened_zero_armor:
					shingetsurin_sound.play()
					create_shingetsurin(global_position, 10)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					zbuster_sound.play()
					create_zbuster(global_position, 3.6)
				else:
					zbuster_sound.play()
					create_zbuster(global_position, 3)
			elif character.saber_node.current_weapon.name == "Rogue-Blade":
				rogueslash2_sound.play()
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			elif character.saber_node.current_weapon.name == "Sigma-Blade":
				sigmablade2_sound.play()
			else:
				saber2_sound.play()
		if slashes == 2:
			animatedSprite.animation = "saber_3"
			if character.saber_node.current_weapon.name == "Saber":
				saber3_sound.play()
			elif character.saber_node.current_weapon.name == "B-Fan":
				bfan3_sound.play()
			elif character.saber_node.current_weapon.name == "D-Glaive":
				dglaive3_sound.play()
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				if CharacterManager.extra_saber_combo and not character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_dash2"
					swordwave_sound.play()
					if CharacterManager.awakened_zero_armor:
						create_swordwave(global_position, 20)
					elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
						create_swordwave(global_position, 12)
					else:
						create_swordwave(global_position, 10)
				elif CharacterManager.extra_saber_combo and character.get_action_pressed("move_down"):
					animatedSprite.animation = "saber_3"
					if CharacterManager.awakened_zero_armor:
						shingetsurin_sound.play()
						create_shingetsurin(global_position, 10)
					elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
						zbuster_sound.play()
						create_zbuster(global_position, 3.6)
					else:
						zbuster_sound.play()
						create_zbuster(global_position, 3)
			elif character.saber_node.current_weapon.name == "Rogue-Blade":
				rogueslash3_sound.play()
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			elif character.saber_node.current_weapon.name == "Sigma-Blade":
				sigmablade3_sound.play()
			else:
				saber3_sound.play()
		if slashes == 3:
			animatedSprite.animation = "saber_4"
			if character.saber_node.current_weapon.name == "Saber":
				saber2_sound.play()
			elif character.saber_node.current_weapon.name == "D-Glaive":
				dglaive4_sound.play()
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				saber_sound.play()
				swordwave_sound.play()
				if CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 10)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 6)
				else:
					create_swordwave(global_position, 5)
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger_sound.play()
			elif character.saber_node.current_weapon.name == "Rogue-Blade":
				rogueslash4_sound.play()
			else:
				saber2_sound.play()
		if slashes == 4:
			animatedSprite.animation = "saber_5"
			if character.saber_node.current_weapon.name == "Saber":
				saber3_sound.play()
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				saber2_sound.play()
				swordwave_sound.play()
				if CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 10)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 6)
				else:
					create_swordwave(global_position, 5)
			elif character.saber_node.current_weapon.name == "V-Hanger":
				hanger2_sound.play()
			else:
				saber3_sound.play()
		if slashes == 5:
			animatedSprite.animation = "saber_6"
			if character.saber_node.current_weapon.name == "Saber":
				saber2_sound.play()
			elif character.saber_node.current_weapon.name == "Z-Breaker":
				saber3_sound.play()
				swordwave_sound.play()
				if CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 10)
				elif CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
					create_swordwave(global_position, 6)
				else:
					create_swordwave(global_position, 5)
			else:
				saber3_sound.play()
	slashes += 1

func create_zbuster(ground_position, damage_value) -> void :
	var instance = zbuster.instance()
	ground_position.y += -9
	instance.damage = damage_value * 2
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_shingetsurin(ground_position,  damage_value) -> void :
	var instance = shingetsurin.instance()
	ground_position.y += -9
	instance.damage = damage_value * 2
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_swordwave(ground_position,  damage_value) -> void :
	var instance = swordwave.instance()
	ground_position.y += -9
	instance.damage = damage_value * 2
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	if not executing:
		if character.is_on_floor():
			return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if not _animation == "saber_1" and not _animation == "saber_2" and not _animation == "saber_3" and not _animation == "saber_4" and not _animation == "saber_5" and not _animation == "saber_6" and not _animation == "saber_shot_normal" and not _animation == "saber_dash" and not _animation == "saber_shot_fast1" and not _animation == "saber_shot_fast2" and not _animation == "saber_dash2":
			return true
		if end_saber_state():
			return true
	else:
		return true
	return false

func _Setup() -> void :
	update_bonus_horizontal_only_conveyor()
	changed_animation = false
	slashing = false
	slashes = 0
	input_buffer = []
	set_saber_animations()
	ending_saber_state = false

func _Update(_delta: float) -> void :
	hitbox_and_position()
	
	if is_in_buffer_window() and character.get_action_just_pressed(actions[0]):
		input_buffer.append(actions[0])
		
	if CharacterManager.extra_saber_combo and CharacterManager.player_character == "Zero":
		if should_add_saber_extra_combo() and input_buffer.size() > 0:
			input_buffer.pop_front()
			set_saber_extra_animations()
	else:
		if should_add_saber_combo() and input_buffer.size() > 0:
			input_buffer.pop_front()
			set_saber_animations()
	
	force_movement(0)
	process_gravity(_delta)
	update_bonus_horizontal_only_conveyor()

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt():
	._Interrupt()
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
