extends Control

# Reference to the DiagonalDashAxl node
var diagonal_dash_node = null
var player_node = null
var display_font = preload("res://src/Fonts/Xclassicfont.fnt")
var background_sprite = preload("res://Axl_mod/Player/Sprites/Ride/AxlDashCounter.png")

# Current dash values
var upward_dashes = 2
var downward_dashes = 1

# Player proximity fade
var base_alpha = 1.0  # Base opacity when player is not near

# Fade in variables (similar to HUD.gd)
var fade_alpha: float = 1.4  # Start faded out like the HUD
var is_fading_in: bool = true
var is_fading_out: bool = false
var pause_tween: SceneTreeTween  # Tween for pause menu fade

func _ready() -> void:
	# Find the player and diagonal dash node
	call_deferred("find_nodes")
	
	# Connect to pause menu signals to hide/show counter
	Event.connect("pause_menu_opened", self, "_on_pause_opened")
	Event.connect("pause_menu_closed", self, "_on_pause_closed")
	
	# Connect to stage start for fade in
	Event.connect("stage_start", self, "_on_stage_start")
	
	# Connect to player death for fade out
	Event.connect("player_death", self, "_on_player_death")
	
	# Connect to check character switch
	Event.listen("character_switch", self, "hide_diagonal_dash_counter")
	Event.listen("character_switch_end", self, "check_player")
	check_player()

func check_player() -> void :
	if CharacterManager.player_character == "Axl":
		show_diagonal_dash_counter()
	else:
		hide_diagonal_dash_counter()

func show_diagonal_dash_counter() -> void :
	self.modulate.a = 1.0

func hide_diagonal_dash_counter() -> void :
	self.modulate.a = 0

func _on_stage_start():
	# Reset fade in when stage starts
	fade_alpha = 1.4
	is_fading_in = true
	is_fading_out = false

func _on_player_death():
	# Fade out when player dies
	is_fading_out = true
	is_fading_in = false

func _on_pause_opened():
	# Don't hide - let the pause menu's black fade cover it (like HUD)
	pass

func _on_pause_closed():
	# Don't need to do anything - it was never hidden
	pass

func find_nodes():
	# Get the player nodes (there may be multiple things in the Player group)
	var player_nodes = get_tree().get_nodes_in_group("Player")
	
	# Find the actual player character (not Hurtbox or other player-group nodes)
	for node in player_nodes:
		# Skip nodes that are clearly not the player character
		if node.name == "Hurtbox" or node.name == "Enemy Collision Detector":
			continue
		
		# Check if this node has DiagonalDashAxl as a child
		if node.has_node("DiagonalDashAxl"):
			player_node = node
			diagonal_dash_node = node.get_node("DiagonalDashAxl")
			break
		
		# Try searching in children
		for child in node.get_children():
			if child.name == "DiagonalDashAxl":
				player_node = node
				diagonal_dash_node = child
				break
			# Also check script path
			if child.get_script() != null:
				var script_path = child.get_script().get_path()
				if "DiagonalDashAxl" in script_path:
					player_node = node
					diagonal_dash_node = child
					break
		
		if diagonal_dash_node != null:
			break

func _process(_delta: float) -> void:
	# Process fade animations (same logic as HUD.gd)
	var true_delta = GameManager.true_delta if GameManager else _delta
	process_fade(true_delta)
	
	# Hide counter during weapon get screen
	if GameManager and GameManager.weapon_got != "none":
		visible = false
		return
	else:
		visible = true
	
	if diagonal_dash_node == null or player_node == null:
		upward_dashes = 0
		downward_dashes = 0
		update()  # Trigger redraw
		return
	
	# Check if player is near the counter for proximity fade
	if player_is_near_counter():
		base_alpha = 0.25
	else:
		base_alpha = 1.0
	
	# Get the dash state
	var upward_dashes_remaining = 0
	var downward_dashes_remaining = 0
	
	# Check wall-privileged upward dashes FIRST (takes priority)
	if diagonal_dash_node.has_wall_dash_privileges:
		var wall_dashes_left = diagonal_dash_node.max_wall_upward_dashes - diagonal_dash_node.wall_upward_dashes_used
		upward_dashes_remaining = wall_dashes_left
	else:
		# Only check normal upward dash if NO wall privileges
		if not diagonal_dash_node.upward_dash_used:
			upward_dashes_remaining = 1
		else:
			upward_dashes_remaining = 0
	
	# Check downward dash
	if not diagonal_dash_node.downward_dash_used:
		downward_dashes_remaining = 1
	else:
		downward_dashes_remaining = 0
	
	# Update values
	upward_dashes = upward_dashes_remaining
	downward_dashes = downward_dashes_remaining
	
	# Trigger redraw
	update()

func player_is_near_counter() -> bool:
	# Check if player's collision shape is overlapping with the counter area
	if not player_node:
		return false
	
	# Get camera screen center
	if not GameManager.camera:
		return false
	
	var screencenter = GameManager.camera.get_camera_screen_center()
	var player_world_pos = player_node.global_position
	
	# Convert player world position to screen position
	var player_screen_pos = player_world_pos - screencenter + Vector2(200, 112)  # 400x224 screen, center is 200,112
	
	# Get player's collision shape size - make it smaller, only the core body
	var player_rect = Rect2(player_screen_pos - Vector2(6, 12), Vector2(12, 24))  # Smaller hitbox: 12x24
	
	# Create a smaller counter hitbox that only covers the actual visible counter (not the full 90x40 control)
	# The actual counter graphic is much smaller - approximately 24x26 pixels
	var counter_screen_pos = rect_global_position
	var counter_rect = Rect2(counter_screen_pos + Vector2(0, 15), Vector2(24, 26))  # Just the visible counter area
	
	# Check if the player's hitbox intersects with the counter rect
	return counter_rect.intersects(player_rect)

func process_fade(delta: float) -> void:
	# Fade in at level start (like HUD)
	if is_fading_in and fade_alpha > 0:
		fade_alpha -= delta * 2  # Same fade speed as HUD
		if fade_alpha <= 0:
			fade_alpha = 0
			is_fading_in = false
	# Fade out when pausing
	elif is_fading_out and fade_alpha < 1:
		fade_alpha += delta * 4  # Faster fade out for pause
		if fade_alpha >= 1:
			fade_alpha = 1
	
	# Trigger redraw to update visuals
	update()

func _draw():
	# Calculate final alpha based on ground state, proximity, AND fade animations
	var final_alpha = 1.0
	
	# When on ground, fade to 30%
	if player_node and player_node.is_on_floor():
		final_alpha = 0.3
	# When in the air and player is near, fade to 15%
	elif base_alpha < 1.0:
		final_alpha = 0.15
	# When in the air and player NOT near, 100%
	else:
		final_alpha = 1.0
	
	# Apply fade animation multiplier (0 = invisible, 1 = no fade effect)
	final_alpha = final_alpha * (1.0 - clamp(fade_alpha, 0, 1))
	
	# Apply pause menu modulate alpha (for tween fade)
	final_alpha = final_alpha * modulate.a
	
	# Draw the background sprite first (behind the text)
	if background_sprite:
		var bg_color = Color(1, 1, 1, final_alpha)
		draw_texture(background_sprite, Vector2(-6.5, 15), bg_color)
	
	# Draw the counter text on top
	if display_font:
		var color = Color(1, 1, 1, final_alpha)
		
		# Draw upward dash counter (left-aligned now)
		var upward_text = "↗ %d" % upward_dashes
		draw_string(display_font, Vector2(-7, 25), upward_text, color)
		
		# Draw downward dash counter below (left-aligned)
		var downward_text = "↘ %d" % downward_dashes
		draw_string(display_font, Vector2(2, 25), downward_text, color)
