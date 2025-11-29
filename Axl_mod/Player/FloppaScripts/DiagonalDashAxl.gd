extends Movement
class_name DiagonalDashFloppaAxl

onready var left_up_tracker: Area2D = $left_up_tracker
onready var right_up_tracker: Area2D = $right_up_tracker
onready var left_down_tracker: Area2D = $left_down_tracker
onready var right_down_tracker: Area2D = $right_down_tracker

export  var dash_duration: = 0.65
export  var diagonal_speed: = 300.0
export  var upward_speed: = - 250.0
export  var downward_speed: = 250.0
export  var invulnerability_duration: = 0.0
export  var hover_effect_offset_up_right_down_left: = Vector2( - 2, 4)
export  var hover_effect_offset_up_left_down_right: = Vector2( - 2, 4)
export  var hover_effect_rotation_up_right_down_left: = 50.0
export  var hover_effect_rotation_up_left_down_right: = 50.0

onready var particles = character.get_node("animatedSprite").get_node("Dash Smoke Particles")
onready var dash_particle = get_node("dash_particle")
onready var hover_effect = character.get_node("animatedSprite").get_node("HoverEffect")
onready var afterimages = character.get_node("animatedSprite").get_node("afterImages")

var ghost_particle
var sprite_effect
var _dash
var emitted_dash: = false
var emitted_hover_effect: = false

# Custom afterimage trail system (fixed 6 sprites)
var diagonal_afterimages: Array = []
var max_diagonal_afterimages: int = 6
var afterimage_spawn_timer: float = 0.0
var afterimage_spawn_interval: float = 0.05  # How often to spawn new afterimage
var dash_direction: int = 0
var is_downward_dash: = false


var upward_dash_used: = false
var downward_dash_used: = false


var wall_upward_dashes_used: = 0
var max_wall_upward_dashes: = 2
var has_wall_dash_privileges: = false


var wall_jump_delay_timer: = 0.0
var wall_jump_delay_duration: = 0.2
var was_wall_sliding: = false


var bounce_cooldown_timer: = 0.0
var bounce_cooldown_duration: = 0.3
var last_bounced_enemy = null
var bounce_immunity_timer: = 0.0
var bounce_immunity_duration: = 0.5
var has_bounced: = false
var is_bouncing: = false
var bounce_start_time: = 0.0
var bounce_invincibility_timer: = 0.0
var bounce_invincibility_duration: = 0.5
var bounce_damage_blocked: = false

# Ground bounce variables
var dash_hold_timer: = 0.0
var dash_hold_threshold: = 0.07
var dash_button_held: = false
var ground_bounce_ready: = false

export  var shot_pos_adjust: = Vector2(18, 4)

var keep_press_timer: = 0.0
var lock_on: = false
var check_over: = false

func get_target() -> Node2D:
	var check_target
	if is_downward_dash:
		if get_facing_direction() > 0:
			check_target = right_down_tracker
		else:
			check_target = left_down_tracker
		var targetdown = check_target.get_closest_target()
		return targetdown
	else:
		if get_facing_direction() > 0:
			check_target = right_up_tracker
		else:
			check_target = left_up_tracker
		var targetup = check_target.get_closest_target()
		return targetup

func get_wall_target() -> Node2D:
	var check_target
	if is_downward_dash:
		if get_facing_direction() > 0:
			check_target = left_down_tracker
		else:
			check_target = right_down_tracker
		var targetdown = check_target.get_closest_target()
		return targetdown
	else:
		if get_facing_direction() > 0:
			check_target = left_up_tracker
		else:
			check_target = right_up_tracker
		var targetup = check_target.get_closest_target()
		return targetup

func increase_keep_press_timer(_delta: float) -> void :
	if character.get_action_pressed("dash"):
		keep_press_timer += _delta
	if not character.get_action_pressed("dash"):
		keep_press_timer = 0.0

func check_lock() -> void :
	if CharacterManager.floppa_axl_auto_lock or character.get_action_pressed("dash") and keep_press_timer > 0.1:
		var targetdown = get_target()
		var targetup = get_target()
		if is_downward_dash:
			if targetdown:
				lock_on = true#check succeed, set diagonal dash animation
			else:
				lock_on = false#fall to check, set normal animation
		else:
			if targetup:
				lock_on = true#check succeed, set diagonal dash animation
			else:
				lock_on = false#fall to check, set normal animation

func wall_check_lock() -> void :
	if CharacterManager.floppa_axl_auto_lock or character.get_action_pressed("dash") and keep_press_timer > 0.1:
		var targetdown = get_wall_target()
		var targetup = get_wall_target()
		if is_downward_dash:
			if targetdown:
				lock_on = true#check succeed, set diagonal dash animation
			else:
				lock_on = false#fall to check, set normal animation
		else:
			if targetup:
				lock_on = true#check succeed, set diagonal dash animation
			else:
				lock_on = false#fall to check, set normal animation

func check_lock_press() -> void :
	if not check_over and character.get_action_pressed("dash") and keep_press_timer > 0.1:
		var targetdown = get_target()
		var targetup = get_target()
		if is_downward_dash:
			if targetdown:
				lock_on = true#check succeed, set diagonal dash animation
			else:
				lock_on = false#fall to check, set normal animation
		else:
			if targetup:
				lock_on = true#check succeed, set diagonal dash animation
			else:
				lock_on = false#fall to check, set normal animation
		if keep_press_timer > 0.11:
			check_over = true

func get_shot_adust_position() -> Vector2:
	return shot_pos_adjust

func _ready() -> void :
	sprite_effect = get_node("duringImage")
	ghost_particle = get_node("particles2D")
	
	
	character.listen("land", self, "reset_diagonal_dash")
	character.listen("wallslide", self, "reset_diagonal_dash")
	
	
	character.listen("walljump", self, "start_wall_jump_delay")
	
	character.listen("jump", self, "check_if_wall_jumping")
	
	
	character.listen("damage", self, "check_bounce_damage_block")
	
	


func _process(delta: float) -> void :
	
	if wall_jump_delay_timer > 0.0:
		wall_jump_delay_timer -= delta
		if wall_jump_delay_timer <= 0.0:
			#print("Wall jump delay expired - diagonal dash available again")
			pass
	
	if bounce_cooldown_timer > 0.0:
		bounce_cooldown_timer -= delta
	
	if bounce_immunity_timer > 0.0:
		bounce_immunity_timer -= delta
		if bounce_immunity_timer <= 0.0:
			last_bounced_enemy = null
	
	
	if bounce_invincibility_timer > 0.0:
		bounce_invincibility_timer -= delta
		character.remove_invulnerability_shader()  # Keep removing shader every frame to prevent flicker
		if bounce_invincibility_timer <= 0.0:
			bounce_damage_blocked = false
			character.remove_invulnerability("bounce_invincibility")
			#print("Bounce invincibility expired (no flash)")
	
	
	if is_bouncing and bounce_start_time > 0:
		var time_since_bounce = (Time.get_ticks_msec() / 1000.0) - bounce_start_time
		if time_since_bounce >= 0.4:
			is_bouncing = false
			bounce_start_time = 0.0
			#print("Bounce animation complete - returning to dash animation")
	
	
	var currently_wall_sliding = character.is_executing("WallSlide")
	if currently_wall_sliding:
		was_wall_sliding = true
		has_wall_dash_privileges = true
		#print("Wall sliding detected - wall dash privileges granted")
	elif was_wall_sliding and not currently_wall_sliding:
		
		get_tree().create_timer(0.1).connect("timeout", self, "reset_wall_sliding_flag")
	
	
	if character.is_on_floor() and has_wall_dash_privileges:
		has_wall_dash_privileges = false
		wall_upward_dashes_used = 0
		#print("Touched ground - wall dash privileges removed, counter reset")

func reset_diagonal_dash():
	#print("=== RESET DIAGONAL DASH CALLED ===")
	#print("Before reset - wall_upward_dashes_used: ", wall_upward_dashes_used, " has_wall_dash_privileges: ", has_wall_dash_privileges)
	upward_dash_used = false
	downward_dash_used = false
	wall_upward_dashes_used = 0
	has_wall_dash_privileges = false
	
	bounce_cooldown_timer = 0.0
	bounce_immunity_timer = 0.0
	last_bounced_enemy = null
	has_bounced = false
	
	bounce_invincibility_timer = 0.0
	bounce_damage_blocked = false
	
	# Remove bounce invulnerability when resetting
	character.remove_invulnerability("bounce_invincibility")
	
	# Clear custom diagonal dash afterimages
	clear_diagonal_afterimages()
	
	#print("After reset - wall_upward_dashes_used: ", wall_upward_dashes_used, " has_wall_dash_privileges: ", has_wall_dash_privileges)
	#print("Diagonal dashes reset - can use both again")

func start_wall_jump_delay():
	wall_jump_delay_timer = wall_jump_delay_duration
	#print("Wall jump executed - diagonal dash blocked for ", wall_jump_delay_duration, " seconds")

func check_if_wall_jumping():
	
	if character.is_executing("WallJump") or character.is_executing("DashWallJump"):
		#print("Detected jump during wall jump execution - starting delay")
		start_wall_jump_delay()
	
	elif was_wall_sliding:
		#print("Detected jump after wall slide - starting delay")
		start_wall_jump_delay()

func reset_wall_sliding_flag():
	was_wall_sliding = false

func check_bounce_damage_block(_damage_value: float, _inflicter: Object) -> void :
	
	if bounce_damage_blocked and bounce_invincibility_timer > 0.0:
		#print("Blocking damage during bounce invincibility (no flash): ", damage_value)
		
		
		character.emit_signal("interrupt_damage")
		return



func is_wall_jump_delay_active() -> bool:
	return wall_jump_delay_timer > 0.0

func start_diagonal_hover_effect():
	
	emitted_hover_effect = false
	
	if not emitted_hover_effect:
		
		hover_effect.visible = true
		hover_effect.playing = true
		hover_effect.frame = 0
		
		#print("FORCING diagonal hover effect to appear")
		
		
		var rotation_angle = 0.0
		var position_offset = Vector2(0, 0)
		
		if is_downward_dash:
			
			if dash_direction == - 1:
				rotation_angle = hover_effect_rotation_up_right_down_left
				position_offset = hover_effect_offset_up_right_down_left
			else:
				rotation_angle = hover_effect_rotation_up_left_down_right
				position_offset = hover_effect_offset_up_left_down_right
		else:
			
			if dash_direction == - 1:
				rotation_angle = hover_effect_rotation_up_left_down_right
				position_offset = hover_effect_offset_up_left_down_right
			else:
				rotation_angle = hover_effect_rotation_up_right_down_left
				position_offset = hover_effect_offset_up_right_down_left
		
		hover_effect.position = position_offset
		hover_effect.rotation_degrees = rotation_angle
		hover_effect.scale.x = 1
		emitted_hover_effect = true
		
		#print("Diagonal hover effect started at position: ", position_offset, " rotation: ", rotation_angle)

func reset_diagonal_hover_effect():
	if emitted_hover_effect:
		hover_effect.visible = false
		hover_effect.playing = false
		hover_effect.rotation_degrees = 0
		hover_effect.scale.x = 1
		emitted_hover_effect = false

func force_diagonal_hover_effect():
	
	
	#print("FORCE applying diagonal hover effect after hover cleanup")
	
	
	emitted_hover_effect = false
	
	hover_effect.visible = true
	hover_effect.playing = true
	hover_effect.frame = 0
	
	
	var rotation_angle = 0.0
	var position_offset = Vector2(0, 0)
	
	if is_downward_dash:
		if dash_direction == - 1:
			rotation_angle = hover_effect_rotation_up_right_down_left
			position_offset = hover_effect_offset_up_right_down_left
		else:
			rotation_angle = hover_effect_rotation_up_left_down_right
			position_offset = hover_effect_offset_up_left_down_right
	else:
		if dash_direction == - 1:
			rotation_angle = hover_effect_rotation_up_left_down_right
			position_offset = hover_effect_offset_up_left_down_right
		else:
			rotation_angle = hover_effect_rotation_up_right_down_left
			position_offset = hover_effect_offset_up_right_down_left
	
	hover_effect.position = position_offset
	hover_effect.rotation_degrees = rotation_angle
	hover_effect.scale.x = 1
	emitted_hover_effect = true
	
	#print("FORCED diagonal hover effect - position: ", position_offset, " rotation: ", rotation_angle)

func force_dash_particle_emission():
	
	#print("FORCE emitting white smoke particles after setup")
	
	
	if particles:
		#print("Forcing white smoke particles (Dash Smoke Particles)...")
		emit_particles(particles, true)
		
		particles.emitting = true
		particles.visible = true
		if particles.has_method("restart"):
			particles.restart()
		#print("White smoke particles forced to emit")
	else:
		#print("ERROR: particles (Dash Smoke Particles) node is null!")
		pass

func end_diagonal_dash_for_hover():
	
	if character.is_executing("HoverAxl") or character.is_executing("Hover"):
		#print("Hover successfully started - ending diagonal dash")
		EndAbility()
	else:
		#print("Hover didn\'t start - keeping diagonal dash active")
		pass

func _Setup() -> void :
	
	#print("FORCING diagonal dash setup - overriding everything")
	
	
	Event.emit_signal("dash")
	
	
	is_downward_dash = character.get_action_pressed("move_down")
	
	
	if is_downward_dash:
		downward_dash_used = true
		#print("Downward diagonal dash used")
	else:
		
		if has_wall_dash_privileges:
			#print("BEFORE increment: wall_upward_dashes_used = ", wall_upward_dashes_used)
			wall_upward_dashes_used += 1
			#print("AFTER increment: wall_upward_dashes_used = ", wall_upward_dashes_used, "/", max_wall_upward_dashes)
		else:
			upward_dash_used = true
			#print("Normal upward diagonal dash used")
	
	
	
	if not emitted_hover_effect:
		start_diagonal_hover_effect()
	
	
	if character.has_node("HoverAxl"):
		var hover_axl = character.get_node("HoverAxl")
		if hover_axl.has_method("cancel_hover"):
			hover_axl.cancel_hover()
		if hover_axl.has_method("EndAbility"):
			hover_axl.EndAbility()
		
		if "hover_locked" in hover_axl:
			hover_axl.hover_locked = false
		if "is_hovering" in hover_axl:
			hover_axl.is_hovering = false
	
	if character.has_node("Hover"):
		var hover_node = character.get_node("Hover")
		if hover_node.has_method("cancel_hover"):
			hover_node.cancel_hover()
		if hover_node.has_method("EndAbility"):
			hover_node.EndAbility()
		if "hover_locked" in hover_node:
			hover_node.hover_locked = false
	
	
	
	call_deferred("force_diagonal_hover_effect")
	
	
	call_deferred("force_dash_particle_emission")
	
	
	dash_direction = character.get_facing_direction()
	
	
	set_direction(dash_direction)
	
	
	#print("DiagonalDash direction: ", dash_direction, " (1=right, -1=left)")
	#print("Diagonal dash used - cannot use again until reset")
	
	update_bonus_horizontal_only_conveyor()
	emit_particles(particles, true)
	character.reduce_hitbox()
	invulnerable(true)
	emitted_dash = false
	changed_animation = false
	has_bounced = false
	is_bouncing = false
	
	# Initialize custom afterimage system for diagonal dash
	afterimage_spawn_timer = 0.0
	diagonal_afterimages.clear()
	
	# Initialize ground bounce variables
	dash_hold_timer = 0.0
	dash_button_held = character.get_action_pressed("dash")
	ground_bounce_ready = false
	
	#print("Ground bounce system initialized - dash held at start: ", dash_button_held)
	
	
	emit_dash_particle()
	
	
	character.animatedSprite.play("dash")
	
	character.play_animation("dash")
	
	
	if is_downward_dash:
		
		if dash_direction == - 1:
			character.animatedSprite.rotation_degrees = - 35
		else:
			character.animatedSprite.rotation_degrees = 35
	else:
		
		if dash_direction == - 1:
			character.animatedSprite.rotation_degrees = 35
		else:
			character.animatedSprite.rotation_degrees = - 35
	
	
	var horizontal_vel = diagonal_speed * dash_direction
	var vertical_vel = downward_speed if is_downward_dash else upward_speed
	#print("Setting horizontal velocity: ", horizontal_vel, " vertical: ", vertical_vel, " (downward: ", is_downward_dash, ")")
	character.set_horizontal_speed(horizontal_vel)
	character.set_vertical_speed(vertical_vel)
	lock_on = false
	check_over = false
	keep_press_timer = 0.0

	check_lock()

func emit_dash_particle():
	if not emitted_dash:
		_dash = dash_particle.emit(dash_direction)
		emitted_dash = true

func _Update(_delta: float) -> void :
	increase_keep_press_timer(_delta)
	process_invulnerability()
	
	# Spawn custom diagonal dash afterimages (max 6)
	spawn_diagonal_afterimage(_delta)
	
	# Track dash button hold for ground bounce
	if character.get_action_pressed("dash"):
		if dash_button_held:
			dash_hold_timer += _delta
			if dash_hold_timer >= dash_hold_threshold and not ground_bounce_ready:
				ground_bounce_ready = true
				#print("Ground bounce READY - dash held for ", dash_hold_timer, " seconds")
		else:
			dash_button_held = true
			dash_hold_timer = _delta
	else:
		dash_button_held = false
		dash_hold_timer = 0.0
		if ground_bounce_ready:
			#print("Dash button released - ground bounce no longer ready")
			pass
		ground_bounce_ready = false
	
	
	if has_bounced and bounce_start_time > 0:
		var time_since_bounce = (Time.get_ticks_msec() / 1000.0) - bounce_start_time
		if time_since_bounce < 0.5:
			check_and_fix_ceiling_clip()
	
	
	check_for_ceiling_bounce()
	
	
	
	if bounce_cooldown_timer <= 0.0:
		
		for i in range(3):
			check_for_enemy_collision()
			if has_bounced:
				break
	
	
	if character.get_action_just_pressed("jump"):
		
		reset_diagonal_hover_effect()
		
		emit_particles(particles, false)
		#print("Hover activated during diagonal dash - allowing hover to start, will end diagonal dash after")
		
		call_deferred("end_diagonal_dash_for_hover")
		return
	
	
	if character.is_executing("HoverAxl") or character.is_executing("Hover"):
		#print("Hover has taken priority - ending diagonal dash completely")
		reset_diagonal_hover_effect()
		
		emit_particles(particles, false)
		
		EndAbility()
		return
	
	if not emitted_dash:
		emit_dash_particle()
	
	
	
	
	
	if not lock_on and not is_bouncing and character.animatedSprite.animation != "dash":
		character.animatedSprite.play("dash")
	elif lock_on and not is_bouncing and character.animatedSprite.animation != "diagonal_dash":
		character.animatedSprite.play("diagonal_dash")
	elif is_bouncing and character.animatedSprite.animation != "rolling":
		character.animatedSprite.play("rolling")
		##print("Forcing rolling animation during bounce")
	
	check_lock_press()
	
	var horizontal_vel = diagonal_speed * dash_direction
	var vertical_vel = downward_speed if is_downward_dash else upward_speed
	if not lock_on:
		character.set_horizontal_speed(horizontal_vel)
		character.set_vertical_speed(vertical_vel)
	elif lock_on:
		if is_downward_dash:
			var targetdown = get_target()
			if targetdown and keep_press_timer > 0.1 or CharacterManager.floppa_axl_auto_lock and targetdown:
				var dir: = Tools.get_angle_between(targetdown, self)
				character.set_horizontal_speed(horizontal_vel * dir.x)
				character.set_vertical_speed(vertical_vel * dir.y)
				character.animatedSprite.rotation_degrees = 0
				#if atan(dir.y/dir.x) < 90 and atan(dir.y/dir.x) > -90:
					#character.animatedSprite.rotation_degrees = atan(dir.y/dir.x)
				#else:
					#character.animatedSprite.rotation_degrees = 0
		else:
			var targetup = get_target()
			if targetup and keep_press_timer > 0.1 or CharacterManager.floppa_axl_auto_lock and targetup:
				var dir: = Tools.get_angle_between(targetup, self)
				character.set_horizontal_speed(horizontal_vel * dir.x)
				character.set_vertical_speed(- vertical_vel * dir.y)
				character.animatedSprite.rotation_degrees = 0
				#if atan(dir.y/dir.x) < 90 and atan(dir.y/dir.x) > -90:
					#character.animatedSprite.rotation_degrees = atan(dir.y/dir.x)
				#else:
					#character.animatedSprite.rotation_degrees = 0
		
		
	set_direction(dash_direction)
	force_movement(abs(horizontal_vel))
	
	#print("Frame update - horizontal_vel: ", horizontal_vel, " dash_direction: ", dash_direction)

func check_and_fix_ceiling_clip():
	
	if bounce_cooldown_timer > 0.0:
		
		return
	
	var space_state = character.get_world_2d().direct_space_state
	
	
	var check_points = [
		Vector2(0, - 20), 
		Vector2( - 8, - 20), 
		Vector2(8, - 20), 
		Vector2(0, - 15), 
	]
	
	var ceiling_clips_detected = 0
	
	for point_offset in check_points:
		var from = character.global_position + point_offset
		var to = from + Vector2(0, - 5)
		
		var result = space_state.intersect_ray(from, to, [character], 1)
		
		if result and result.has("collider"):
			
			var collider = result.collider
			if not (collider.is_in_group("Enemies") or collider.is_in_group("Bosses")):
				ceiling_clips_detected += 1
	
	
	
	if ceiling_clips_detected >= 2:
		#print("CEILING CLIPPING DETECTED! Player head is inside solid ceiling (", ceiling_clips_detected, " points)")
		
		
		character.global_position.y += 15
		character.set_vertical_speed(100)
		
		
		if character.has_node("WallSlide"):
			var wall_slide_node = character.get_node("WallSlide")
			if wall_slide_node.has_method("EndAbility"):
				wall_slide_node.EndAbility()
			if "wallgrab_direction" in wall_slide_node:
				wall_slide_node.wallgrab_direction = 0
		
		
		if character.is_executing("WallSlide"):
			character.emit_signal("interrupt", "WallSlide")
		
		#print("Forced player out of ceiling clip")

func check_for_ceiling_bounce():
	
	if not is_downward_dash and not has_bounced:
		var current_speed = Vector2(character.get_horizontal_speed(), character.get_vertical_speed())
		
		
		var hitting_ceiling = false
		var detection_method = ""
		
		
		if character.is_on_ceiling():
			hitting_ceiling = true
			detection_method = "is_on_ceiling"
		
		
		var space_state = character.get_world_2d().direct_space_state
		var ceiling_check = space_state.intersect_ray(
			character.global_position + Vector2(0, - 2), 
			character.global_position + Vector2(0, - 6), 
			[character], 
			1
		)
		
		if ceiling_check and ceiling_check.has("collider"):
			var distance = character.global_position.distance_to(ceiling_check.position)
			
			if distance <= 5:
				hitting_ceiling = true
				detection_method = "close_raycast_" + str(distance)
		
		
		if current_speed.y >= - 50 and timer > 0.1:
			var contact_check = space_state.intersect_ray(
				character.global_position + Vector2(0, - 1), 
				character.global_position + Vector2(0, - 4), 
				[character], 
				1
			)
			if contact_check and contact_check.has("collider"):
				var distance = character.global_position.distance_to(contact_check.position)
				
				if distance <= 3:
					hitting_ceiling = true
					detection_method = "contact_" + str(distance)
		
		
		if hitting_ceiling:
			#print("CEILING BOUNCE! Method: ", detection_method, " Speed: ", current_speed.y)
			
			
			var new_vertical_speed = 200
			if current_speed.y < 0:
				new_vertical_speed = abs(current_speed.y) * 1.2 + 150
			
			var new_horizontal_speed = current_speed.x
			if abs(new_horizontal_speed) < 200:
				new_horizontal_speed = 200 * sign(current_speed.x) if current_speed.x != 0 else 200 * dash_direction
			
			
			is_downward_dash = true
			
			
			character.set_vertical_speed(new_vertical_speed)
			character.set_horizontal_speed(new_horizontal_speed)
			
			
			#print("Applied bounce velocities - H:", new_horizontal_speed, " V:", new_vertical_speed)
			
			
			if dash_direction == - 1:
				character.animatedSprite.rotation_degrees = - 35
			else:
				character.animatedSprite.rotation_degrees = 35
			
			
			reset_diagonal_hover_effect()
			start_diagonal_hover_effect()
			
			check_lock()#check to reset animation
			
			timer = max(0, timer - 0.2)

func check_for_ground_bounce():
	# Only bounce if we're doing a downward dash and the ground bounce is ready
	if is_downward_dash and ground_bounce_ready and character.is_on_floor():
		#print("GROUND BOUNCE! Dash was held for ", dash_hold_timer, " seconds")
		
		# Calculate bounce velocities
		var bounce_vertical_speed = upward_speed * 0.8  # Slightly less powerful than ceiling bounce
		var bounce_horizontal_speed = character.get_horizontal_speed()
		
		# Make sure we have enough horizontal momentum
		if abs(bounce_horizontal_speed) < 150:
			bounce_horizontal_speed = 150 * dash_direction
		
		# Switch to upward dash
		is_downward_dash = false
		
		# Apply bounce velocities
		character.set_vertical_speed(bounce_vertical_speed)
		character.set_horizontal_speed(bounce_horizontal_speed)
		
		#print("Applied ground bounce velocities - H:", bounce_horizontal_speed, " V:", bounce_vertical_speed)
		
		# Update sprite rotation for upward dash
		if dash_direction == -1:
			character.animatedSprite.rotation_degrees = 35
		else:
			character.animatedSprite.rotation_degrees = -35
		
		# Reset and restart hover effect
		reset_diagonal_hover_effect()
		start_diagonal_hover_effect()
		
		# Reset ground bounce state
		ground_bounce_ready = false
		dash_hold_timer = 0.0
		
		# Extend dash duration slightly
		timer = max(0, timer - 0.15)
		
		check_lock()#check to reset animation
		
		return true
	
	return false

func check_for_enemy_collision():
	
	
	var space_state = character.get_world_2d().direct_space_state
	
	
	var check_positions = [
		Vector2(0, 0), 
		Vector2(20, 0), 
		Vector2( - 20, 0), 
		Vector2(0, - 20), 
		Vector2(0, 20), 
		Vector2(15, 15), 
		Vector2( - 15, 15), 
		Vector2(15, - 15), 
		Vector2( - 15, - 15), 
		
		Vector2(25, 10), 
		Vector2( - 25, 10), 
		Vector2(10, 25), 
		Vector2( - 10, 25), 
		
		Vector2( - 8, 0), 
		Vector2(8, 0), 
		Vector2(0, - 8), 
		Vector2(0, 8), 
	]
	
	
	if is_downward_dash:
		var forward_direction = Vector2(dash_direction * 30, 20)
		check_positions.append(forward_direction)
		check_positions.append(Vector2(dash_direction * 25, 15))
		check_positions.append(Vector2(dash_direction * 35, 25))
		#print("Downward dash - added forward detection positions")
	
	for offset in check_positions:
		var from = character.global_position
		var to = character.global_position + offset
		
		
		var result = space_state.intersect_ray(from, to, [character], 8)
		
		if result and result.has("collider"):
			var collider = result.collider
			if collider and (collider.is_in_group("Enemies") or collider.is_in_group("Bosses")):
				
				if collider != last_bounced_enemy:
					
					if is_enemy_alive_and_bounceble(collider):
						
						#print("Enemy collision detected at offset: ", offset, " during ", ("downward" if is_downward_dash else "upward"), " dash")
						perform_enemy_bounce(collider)
						break

func is_enemy_alive_and_bounceble(enemy) -> bool:
	
	if enemy.has_method("has_health") and not enemy.has_health():
		#print("Enemy has no health - skipping bounce")
		return false
	
	
	if "emitted_zero_health" in enemy and enemy.emitted_zero_health:
		#print("Enemy is dying (emitted_zero_health) - skipping bounce")
		return false
	
	
	if enemy.has_node("Damage"):
		var damage_node = enemy.get_node("Damage")
		if "active" in damage_node and not damage_node.active:
			#print("Enemy damage deactivated - skipping bounce")
			return false
	
	
	if enemy.has_method("is_executing"):
		if enemy.is_executing("EnemyDeath") or enemy.is_executing("Death"):
			#print("Enemy is executing death - skipping bounce")
			return false
	
	
	if "current_health" in enemy and enemy.current_health <= 0:
		#print("Enemy current_health <= 0 - skipping bounce")
		return false
	
	
	return true

func perform_enemy_bounce(enemy):
	#print("Diagonal dash hit enemy: ", enemy.name)
	
	bounce_cooldown_timer = bounce_cooldown_duration
	bounce_immunity_timer = bounce_immunity_duration
	last_bounced_enemy = enemy
	has_bounced = true
	
	
	bounce_invincibility_timer = bounce_invincibility_duration
	bounce_damage_blocked = true
	
	# Add invulnerability without flicker
	character.add_invulnerability("bounce_invincibility")
	character.remove_invulnerability_shader()  # Prevent flicker effect
	#print("Bounce invincibility activated for ", bounce_invincibility_duration, " seconds (no flash)")
	
	# Regenerate the dash that was used
	if is_downward_dash:
		downward_dash_used = false
		#print("Downward dash regenerated after hitting enemy!")
	else:
		# For upward dashes, check if it was a wall dash or normal dash
		if has_wall_dash_privileges and wall_upward_dashes_used > 0:
			# Regenerate wall dash by decrementing the counter
			#print("BEFORE regeneration: wall_upward_dashes_used = ", wall_upward_dashes_used)
			wall_upward_dashes_used -= 1
			#print("AFTER regeneration: wall_upward_dashes_used = ", wall_upward_dashes_used, "/", max_wall_upward_dashes)
		else:
			# Regenerate normal upward dash
			upward_dash_used = false
			#print("Normal upward dash regenerated after hitting enemy!")
	
	if enemy.has_method("damage"):
		enemy.damage(3, character)
	
	var bounce_horizontal = - character.get_horizontal_speed() * 0.75
	
	
	var bounce_vertical = upward_speed * 0.75
	
	
	if is_downward_dash:
		bounce_vertical = upward_speed * 0.75
		is_downward_dash = false
	
	
	character.set_horizontal_speed(bounce_horizontal)
	character.set_vertical_speed(bounce_vertical)
	
	
	
	#print("Enkoukyaku-style bounce applied - H:", bounce_horizontal, " V:", bounce_vertical)
	
	
	dash_direction = 1 if bounce_horizontal > 0 else - 1
	set_direction(dash_direction)
	
	
	
	if bounce_horizontal < 0:
		character.animatedSprite.rotation_degrees = 35
	else:
		character.animatedSprite.rotation_degrees = - 35
	
	
	reset_diagonal_hover_effect()
	start_diagonal_hover_effect()
	
	
	timer = dash_duration - 0.15


	
	is_bouncing = true
	bounce_start_time = Time.get_ticks_msec() / 1000.0
	
	
	character.animatedSprite.play("rolling")
	character.play_animation("rolling")
	#print("Enkoukyaku-style bounce complete")

func synchronize_sprite_effect():
	if invulnerability_duration > 0:
		sprite_effect.frames = character.animatedSprite.frames
		sprite_effect.frame = character.animatedSprite.frame
		sprite_effect.set_scale(Vector2(character.get_facing_direction(), 1))
		ghost_particle.set_scale(Vector2(character.get_facing_direction(), 1))

func _Interrupt():
	if not changed_animation:
		character.call_deferred("increase_hitbox")
	
	character.animatedSprite.rotation_degrees = 0
	
	# Reset ground bounce state
	dash_hold_timer = 0.0
	dash_button_held = false
	ground_bounce_ready = false
	
	reset_diagonal_hover_effect()
	emit_particles(particles, false)
	invulnerable(false)
	is_bouncing = false
	
	
	if not has_bounced:
		bounce_invincibility_timer = 0.0
		bounce_damage_blocked = false
	
	
	if has_bounced:
		# Check if hover jump option is enabled
		var hover_jump_enabled = false  # Default behavior
		if CharacterManager.floppa_axl_auto_hover:
			hover_jump_enabled = true
		
		if hover_jump_enabled:
			#print("Bounce ended - activating hover (Hover Jump option: ON)")
			
			character.set_direction( - dash_direction)
			
			call_deferred("activate_hover_after_bounce")
		else:
			#print("Bounce ended - NOT activating hover (Hover Jump option: OFF)")
			# Face the opposite direction after bounce ends
			character.set_direction(-dash_direction)
			#print("Facing opposite direction after bounce: ", -dash_direction)
	
	._Interrupt()

func activate_hover_after_bounce():
	
	#print("DEBUG: Looking for hover nodes...")
	
	
	var hover_node = null
	if character.has_node("Hover"):
		hover_node = character.get_node("Hover")
		#print("Found Hover node")
	elif character.has_node("HoverAxl"):
		hover_node = character.get_node("HoverAxl")
		#print("Found HoverAxl node")
	else:
		
		#print("Available character nodes:")
		for child in character.get_children():
			#print("- ", child.name, " (", child.get_class(), ")")
			pass
		#print("No hover node found!")
		return
	
	if not character.is_on_floor():
		#print("Player in air, activating hover...")
		
		
		if hover_node.has_method("reset_jump_count"):
			hover_node.reset_jump_count()
			#print("Air jumps reset")
		
		
		if "current_air_jumps" in hover_node:
			hover_node.current_air_jumps = max(1, hover_node.max_air_jumps)
			#print("Set air jumps to: ", hover_node.current_air_jumps)
		
		
		if "hover_locked" in hover_node:
			hover_node.hover_locked = true
			#print("Hover locked set to true")
		
		
		if character.is_executing("Hover"):
			#print("Hover already executing, ending it first")
			hover_node.EndAbility()
		
		
		if hover_node.has_method("ExecuteOnce"):
			hover_node.ExecuteOnce()
			#print("ExecuteOnce called on hover")
		
		#print("Hover activation attempted after enemy bounce")
	else:
		#print("Player on floor, cannot activate hover")
		pass

func invulnerable(state: bool):
	if invulnerability_duration > 0:
		if state:
			character.add_invulnerability(name)
		else:
			character.remove_invulnerability(name)
		sprite_effect.visible = state
		ghost_particle.emitting = state

func process_invulnerability():
	if invulnerability_duration > 0:
		synchronize_sprite_effect()
		if timer > invulnerability_duration:
			invulnerable(false)

func _StartCondition() -> bool:
	
	if is_wall_jump_delay_active():
		#print("Diagonal dash blocked - wall jump delay active (", wall_jump_delay_timer, " seconds remaining)")
		return false
	
	
	if character.is_shooting:
		return false
	if character.is_executing("Shot") or character.is_executing("AltFire"):
		return false
	
	
	if facing_a_wall() and not character.is_executing("WallSlide"):
		return false
	
	
	var up_dash = character.get_action_pressed("move_up") and character.get_action_just_pressed("dash")
	var down_dash = character.get_action_pressed("move_down") and character.get_action_just_pressed("dash")
	
	
	if up_dash:
		
		if not character.get_action_pressed("move_down"):
			
			if has_wall_dash_privileges:
				
				if wall_upward_dashes_used < max_wall_upward_dashes:
					#print("Wall-privileged upward diagonal dash START CONDITION MET (", wall_upward_dashes_used + 1, "/", max_wall_upward_dashes, ")")
					return true
				else:
					#print("Wall upward dashes exhausted (", wall_upward_dashes_used, "/", max_wall_upward_dashes, ")")
					return false
			else:
				
				if not upward_dash_used:
					#print("Normal upward dash START CONDITION MET")
					return true
				else:
					#print("Normal upward dash already used")
					return false
	
	
	if down_dash:
		if not character.is_on_floor():
			
			if not character.get_action_pressed("move_up"):
				
				if not downward_dash_used:
					return true
	
	return false

func _EndCondition() -> bool:
	# Check for timer expiration
	if timer > dash_duration:
		return true
	
	# Check for ground impact
	if character.is_on_floor() and is_downward_dash:
		# Try ground bounce first
		if check_for_ground_bounce():
			return false  # Don't end dash, continue with ground bounce
		else:
			return true   # End dash normally
	
	# Check for wall collision
	if facing_a_wall():
		var wall_bounced = auto_transition_to_wall_slide()
		if wall_bounced:
			return false  # Don't end dash, continue with wall bounce
		else:
			return true   # End dash normally (wall slide transition)
		
	return false

func auto_transition_to_wall_slide():
	
	# Check if auto wall slide is enabled
	var auto_wall_slide = false  # Default behavior
	if CharacterManager.floppa_axl_auto_cling_wall:
		auto_wall_slide = true
	
	var wall_direction = character.is_colliding_with_wall()
	if wall_direction != 0:
		if auto_wall_slide:
			# Auto wall slide is ON - always stick to wall
			#print("Auto-transitioning to wall slide, wall direction: ", wall_direction)
			
			var wall_slide_node = character.get_node("WallSlide")
			if wall_slide_node:
				wall_slide_node.wallgrab_direction = wall_direction
				character.set_direction(-wall_direction)
			
			character.emit_signal("wallslide")
			return false  # Return false to indicate wall slide transition (end dash)
		else:
			# Auto wall slide is OFF - check if player is pressing toward the wall
			var pressing_toward_wall = false
			
			wall_check_lock()#check to reset animation
			
			# Check if player is holding the direction toward the wall
			if wall_direction == 1:  # Wall is to the right
				pressing_toward_wall = character.get_action_pressed("move_right")
			elif wall_direction == -1:  # Wall is to the left
				pressing_toward_wall = character.get_action_pressed("move_left")
			
			if pressing_toward_wall:
				# Player is holding toward the wall - stick to wall (wall slide)
				#print("Player holding toward wall - sticking to wall despite auto wall slide being off")
				
				var wall_slide_node = character.get_node("WallSlide")
				if wall_slide_node:
					wall_slide_node.wallgrab_direction = wall_direction
					character.set_direction(-wall_direction)
				
				character.emit_signal("wallslide")
				return false  # Return false to indicate wall slide transition (end dash)
			else:
				# Player is NOT holding toward the wall - perform wall bounce
				#print("Player NOT holding toward wall - performing wall bounce")
				perform_wall_bounce()
				return true  # Return true to indicate wall bounce occurred (don't end dash)
	
	return false

func perform_wall_bounce():
	#print("WALL BOUNCE! Auto wall slide is disabled")
	
	var wall_direction = character.is_colliding_with_wall()
	var current_speed = Vector2(character.get_horizontal_speed(), character.get_vertical_speed())
	
	# Calculate bounce velocities - reverse horizontal direction and maintain/boost vertical
	var bounce_horizontal_speed = -current_speed.x * 0.8  # Reverse direction with slight dampening
	var bounce_vertical_speed = current_speed.y
	
	# Ensure minimum bounce speeds for good feel
	if abs(bounce_horizontal_speed) < 150:
		bounce_horizontal_speed = 150 * -wall_direction  # Bounce away from wall
	
	# If moving upward, maintain upward momentum; if downward, convert some to upward
	if current_speed.y < 0:  # Moving up
		bounce_vertical_speed = current_speed.y * 0.9  # Maintain most upward momentum
	else:  # Moving down
		bounce_vertical_speed = -abs(current_speed.y) * 0.6  # Convert some downward to upward
	
	# Apply bounce velocities
	character.set_horizontal_speed(bounce_horizontal_speed)
	character.set_vertical_speed(bounce_vertical_speed)
	
	#print("Applied wall bounce velocities - H:", bounce_horizontal_speed, " V:", bounce_vertical_speed)
	
	# Update dash direction to match new horizontal direction
	dash_direction = 1 if bounce_horizontal_speed > 0 else -1
	set_direction(dash_direction)
	
	# Update sprite rotation for new direction
	if is_downward_dash:
		if dash_direction == -1:
			character.animatedSprite.rotation_degrees = -35
		else:
			character.animatedSprite.rotation_degrees = 35
	else:
		if dash_direction == -1:
			character.animatedSprite.rotation_degrees = 35
		else:
			character.animatedSprite.rotation_degrees = -35
	
	# Reset and restart hover effect for new direction
	reset_diagonal_hover_effect()
	start_diagonal_hover_effect()
	
	# Grant 2 upward dashes after wall bounce (only when auto wall slide is off)
	wall_upward_dashes_used = 0
	max_wall_upward_dashes = 2
	has_wall_dash_privileges = true
	#print("Wall bounce granted 2 upward dashes - counter reset to 0/2")
	
	# Extend dash duration slightly to accommodate the bounce
	timer = max(0, timer - 0.15)

func change_animation_if_falling(_s) -> void :
	
	pass

func spawn_diagonal_afterimage(delta: float) -> void:
	afterimage_spawn_timer += delta
	
	# Clean up invalid afterimages from the array
	for i in range(diagonal_afterimages.size() - 1, -1, -1):
		if not is_instance_valid(diagonal_afterimages[i]):
			diagonal_afterimages.remove(i)
	
	# Only spawn if we have less than max afterimages and enough time has passed
	if afterimage_spawn_timer >= afterimage_spawn_interval and diagonal_afterimages.size() < max_diagonal_afterimages:
		afterimage_spawn_timer = 0.0
		
		# Create new afterimage sprite
		var afterimage = AnimatedSprite.new()
		afterimage.frames = character.animatedSprite.frames
		afterimage.animation = character.animatedSprite.animation
		afterimage.frame = character.animatedSprite.frame
		afterimage.playing = false
		afterimage.global_position = character.animatedSprite.global_position
		afterimage.rotation_degrees = character.animatedSprite.rotation_degrees
		afterimage.scale = character.animatedSprite.scale
		afterimage.flip_h = character.animatedSprite.flip_h
		afterimage.flip_v = character.animatedSprite.flip_v
		afterimage.centered = character.animatedSprite.centered
		afterimage.offset = character.animatedSprite.offset
		afterimage.z_index = 1
		
		# Apply shader effect (same as the original afterImages system)
		var material = ShaderMaterial.new()
		material.shader = load("res://Zero_mod/Player/DashShader.shader")
		var shader_color = character.animatedSprite.material.get_shader_param("R_AxlAfterimagesColor1")
		if shader_color:
			material.set_shader_param("display_color", shader_color)
		else:
			material.set_shader_param("display_color", Color(1, 1, 1, 0.6))
		afterimage.material = material
		afterimage.modulate = Color(1, 1, 1, 0.6)
		
		# Add to scene
		get_tree().current_scene.add_child(afterimage)
		diagonal_afterimages.append(afterimage)
		
		# Fade out and delete
		var tween = afterimage.create_tween()
		tween.tween_property(afterimage, "modulate:a", 0.0, 0.25)
		tween.tween_callback(afterimage, "queue_free")

func clear_diagonal_afterimages() -> void:
	# Remove all existing afterimages
	for afterimage in diagonal_afterimages:
		if is_instance_valid(afterimage):
			afterimage.queue_free()
	diagonal_afterimages.clear()

