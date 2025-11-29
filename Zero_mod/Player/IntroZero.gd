extends EventAbility
class_name IntroZero

onready var debug_skip_intro = character.skip_intro
export  var beam_speed: = 420.0
export  var enable_movement: = true
var descending: = false
onready var animatedSprite = get_parent().get_node("animatedSprite")
onready var thunder = get_node("audioStreamPlayer2")
onready var asobiwaowarida = get_node("asobiwaowarida")
onready var awakenend = get_node("awaken_end")
onready var boom = get_node("boom")
onready var awakeneffect = $awakeneffect
onready var awakeneffectex = $awakeneffectex

func _ready() -> void :
	animatedSprite.connect("animation_finished", self, "on_animation_finished")
	if debug_skip_intro:
		character.activate()
		Event.emit_signal("x_appear")
		return
	if CharacterManager.player_character == "Zero" and CharacterManager.awakened_zero_armor:
		animation = "awaken_beam"
		beam_speed = 60.0
		sound = preload("res://Zero_mod/SFX/awakened_loop.ogg")

func _Setup():
	if debug_skip_intro:
		EndAbility()
		return
	character.deactivate()
	character.stop_all_movement()
	descending = true
	animatedSprite.position.y = position.y - 160

func _Update(_delta):
	if descending:
		if animatedSprite.global_position.y < global_position.y - 8:
			animatedSprite.global_position.y += beam_speed * _delta
		else:
			animatedSprite.position.y = - 4
			if not at_correct_height():
				character.move_y(beam_speed * _delta)
			else:
				play_animation_once("beam_in")
				Event.emit_signal("beamin")
				descending = false
				if CharacterManager.player_character == "Zero" and CharacterManager.awakened_zero_armor:
					play_animation_once("awaken_land")
	else:
		if character.get_animation() == "beam_equip":
			process_gravity(_delta)
			if timer > 0.55 and timer < 1:
				thunder.play()
				Event.emit_signal("x_appear")
				timer = 1
		elif character.get_animation() == "awaken_equip":
			process_gravity(_delta)
			if timer > 0 and timer < 0.1:
				awakeneffect.frame = 0
				if CharacterManager.awakened_zero_full_power_max:
					awakeneffectex.frame = 0
			if timer > 0.1 and timer < 0.11:
				boom.play()
			if timer > 0.25 and timer < 0.26:
				awakenend.play()
			if timer > 1.3 and timer < 1.5:
				Event.emit_signal("x_appear")
				timer = 2
				if CharacterManager.awakened_zero_full_power_max:
					asobiwaowarida.play()

func on_animation_finished():
	if executing:
		if character.get_animation() == "beam_in":
			play_animation_once("beam_equip")
			timer = 0
		elif character.get_animation() == "awaken_land":
			play_animation_once("awaken_equip")
			timer = 0
		elif character.get_animation() == "beam_equip":
			EndAbility()
		elif character.get_animation() == "awaken_equip":
			EndAbility()

func _Interrupt():
	if character.is_current_player:
		if enable_movement:
			character.activate()
			Event.emit_signal("gameplay_start")

func _EndCondition() -> bool:
	return false

func is_high_priority() -> bool:
	return true

func is_colliding_with_wall(wallcheck_distance: = 8, vertical_correction: = 8) -> int:
	if raycast(Vector2(global_position.x + wallcheck_distance, global_position.y + vertical_correction)):
		return 1
	elif raycast(Vector2(global_position.x - wallcheck_distance, global_position.y + vertical_correction)):
		return - 1
	
	return 0
	
func at_correct_height() -> bool:
	var ground_y = get_ground_height()
	if global_position.y + 16 <= ground_y:
		return false
	else:
		character.set_y(ground_y - 15)
		return true

func get_ground_height() -> float:
	var intersection = (raycast(Vector2(global_position.x, global_position.y + 1000)).position.y)
	return intersection

func raycast(target_position: Vector2) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	return space_state.intersect_ray(global_position, target_position, [self], character.collision_mask)
