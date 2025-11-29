extends Movement
class_name WallSlideFloppaAxl

var excluded_animations = [
	"shot_slide", 
]

export  var start_delay: = 0.16
export  var block_timer: = 0.0

onready var particles = character.get_node("animatedSprite").get_node("WallSlide Particles")

var wall_object = null
var last_wall_y = 0.0
var last_wall_x = 0.0

var horizontal_speed = 90
var wallgrab_direction: = 0
var stop_shooting_timer: = 0.0
var was_shooting: = false
var slide_down_delay_timer: = 0.0
var slide_down_delay_duration: = 0.25

func _check_for_wall():
	for i in range(character.get_slide_count()):
		var collision = character.get_slide_collision(i)
		if collision.collider:
			wall_object = collision.collider
			last_wall_y = wall_object.global_position.y
			last_wall_x = wall_object.global_position.x
			return
	wall_object = null

func _Setup() -> void :
	wall_object = null
	last_wall_y = 0.0
	last_wall_x = 0.0
	slide_down_delay_timer = 0.0
	character.emit_signal("wallslide")
	
	var pressed_dir = get_pressed_direction()
	var wall_dir = character.is_colliding_with_wall()
	
	# Check if auto wall slide is enabled
	var auto_wall_slide = true  # Default behavior
	if CharacterManager.floppa_axl_auto_cling_wall:
		auto_wall_slide = true
	
	if auto_wall_slide:
		# AUTO MODE: Stick to wall automatically when wall detected
		if pressed_dir == 0 and wall_dir != 0:
			# Auto wall slide - wall direction detected, face away from wall
			wallgrab_direction = wall_dir
			character.set_direction(-wall_dir)
			#print("Auto wall slide setup - wall direction: ", wall_dir, " facing: ", -wall_dir)
		else:
			# Player is pressing a direction
			character.set_direction(-pressed_dir)
			wallgrab_direction = pressed_dir
			#print("Auto wall slide setup - pressed direction: ", pressed_dir)
	else:
		# MANUAL MODE: At this point we know the conditions are met from _StartCondition
		character.set_direction(-pressed_dir)
		wallgrab_direction = pressed_dir
		#print("Manual wall slide setup - holding towards wall: ", pressed_dir, " facing: ", -pressed_dir)
	
	_check_for_wall()

func _Update(_delta: float) -> void :
	# Note: Removed the continuous checking that forced button holding
	# Once wall sliding starts, player stays on wall until normal end conditions
	
	character.set_horizontal_speed(horizontal_speed * wallgrab_direction)
	
	if wall_object:
		var current_wall_y = wall_object.global_position.y
		var current_wall_x = wall_object.global_position.x
		var wall_y_movement = current_wall_y - last_wall_y
		var wall_x_movement = current_wall_x - last_wall_x

		# Move with the wall object (both horizontal and vertical movement)
		if wall_y_movement != 0:
			character.global_position.y += wall_y_movement
		if wall_x_movement != 0:
			character.global_position.x += wall_x_movement
			
		last_wall_y = current_wall_y
		last_wall_x = current_wall_x
	
	if delay_has_expired():
		
		var is_pressing_down = character.get_action_pressed("move_down")
		
		
		var is_shooting = character.is_shooting or character.is_executing("Shot") or character.is_executing("AltFire")
		
		if is_pressing_down and not is_shooting:
			
			slide_down_delay_timer += _delta
			
			
			if slide_down_delay_timer >= slide_down_delay_duration:
				
				emit_particles(particles, true)
				character.set_vertical_speed(100)
			else:
				
				emit_particles(particles, false)
				character.set_vertical_speed(0)
		else:
			
			slide_down_delay_timer = 0.0
			emit_particles(particles, false)
			character.set_vertical_speed(0)
		
		
		
		
		
		if was_shooting and not is_shooting:
			stop_shooting_timer = 0.0
		was_shooting = is_shooting
		
		
		if not is_shooting:
			stop_shooting_timer += _delta
		
		
		if not is_shooting:
			var current_animation = character.get_animation()
			if stop_shooting_timer >= 0.7:
				if current_animation != "slide":
					character.play_animation("slide")
					character.animatedSprite.set_frame(2)
				elif character.animatedSprite.frame != 2:
					character.animatedSprite.set_frame(2)
			

func _StartCondition() -> bool:
	# Check if auto wall slide is enabled FIRST - complete override
	var auto_wall_slide = true  # Default behavior
	if CharacterManager.floppa_axl_auto_cling_wall:
		auto_wall_slide = true
	
	# If auto wall slide is OFF, completely block wall sliding except for very specific conditions
	if not auto_wall_slide:
		#print("Manual mode active - checking conditions...")
		
		# NEVER allow wall slide during any dash or special moves
		if character.is_executing("DiagonalDash") or character.is_executing("DiagonalDashAxl") or character.is_executing("Dash"):
			#print("Manual mode: During dash move - COMPLETELY BLOCKED")
			return false
		
		# Only allow if player is ACTIVELY and DELIBERATELY holding towards wall
		var pressed_dir = get_pressed_direction()
		var wall_dir = character.is_colliding_with_wall()
		
		# Must be actively holding a direction AND it must match the wall direction
		if pressed_dir == 0 or pressed_dir != wall_dir:
			#print("Manual mode: Not actively holding towards wall (pressed:", pressed_dir, " wall:", wall_dir, ") - BLOCKED")
			return false
		
		# Additional check: make sure player has been holding the direction for a bit
		# This prevents accidental wall slides from brief inputs
		#print("Manual mode: Actively holding towards wall - allowing")
	else:
		#print("Auto mode active - allowing wall slide")
		pass
	
	# Continue with normal wall slide checks only if we passed the option check
	if not character.is_on_floor() and not block_timer > 0:
		if character.is_colliding_with_wall() != 0:
			if character.get_vertical_speed() > 0:
				return true
	return false

func _EndCondition() -> bool:
	if character.is_on_floor():
		Log("Floor detected")
		return true
	
	if not character.is_in_reach_for_walljump():
		Log("No wall detected")
		block_timer = 0.01
		return true
		
	
	
	
	return false

func _physics_process(delta: float) -> void :
	if block_timer > 0:
		block_timer += delta
		if block_timer > 0.15:
			block_timer = 0

func _Interrupt():
	if character.get_vertical_speed() > 0:
		character.set_vertical_speed(40)
	character.set_horizontal_speed(0)
	emit_particles(particles, false)

func delay_has_expired() -> bool:
	return timer > start_delay
	
func should_execute_on_hold() -> bool:
	return true
