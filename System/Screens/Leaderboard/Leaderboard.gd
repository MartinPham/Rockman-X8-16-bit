extends Node

var VERSION = "1.0.0.4"
var server_url = "https://mmxdzmleaderboards.glitch.me/"
const API_KEY = "6b0e41fe5449ea66eb1240f96ffc9fc059e2aa82a891dd1c1168f56013da6bba"
signal leaderboard_updated(response_data)

var categories = ["any%", "low%", "100%", "x%", "zero%", "axl%"]
var current_category = categories[0]

var started_fresh_game = false
var started_as = ""

var collectibles_x = [
	"sunflower_weapon", 
	"antonion_weapon", 
	"mantis_weapon", 
	"manowar_weapon", 
	"panda_weapon", 
	"trilobyte_weapon", 
	"yeti_weapon", 
	"rooster_weapon", 
	
	"life_up_sunflower", 
	"life_up_antonion", 
	"life_up_mantis", 
	"life_up_manowar", 
	"life_up_panda", 
	"life_up_trilobyte", 
	"life_up_yeti", 
	"life_up_rooster", 
	
	"subtank_sunflower", 
	"subtank_trilobyte", 
	"subtank_yeti", 
	"subtank_rooster", 
	
	"hermes_head", 
	"hermes_arms", 
	"hermes_body", 
	"hermes_legs", 
	"icarus_head", 
	"icarus_arms", 
	"icarus_body", 
	"icarus_legs", 
	]

var collectibles = [
	"sunflower_weapon", 
	"antonion_weapon", 
	"mantis_weapon", 
	"manowar_weapon", 
	"panda_weapon", 
	"trilobyte_weapon", 
	"yeti_weapon", 
	"rooster_weapon", 
	
	"life_up_sunflower", 
	"life_up_antonion", 
	"life_up_mantis", 
	"life_up_manowar", 
	"life_up_panda", 
	"life_up_trilobyte", 
	"life_up_yeti", 
	"life_up_rooster", 
	
	"subtank_sunflower", 
	"subtank_trilobyte", 
	"subtank_yeti", 
	"subtank_rooster", 
	]
	
var x_armors = [
	"hermes_head", 
	"hermes_arms", 
	"hermes_body", 
	"hermes_legs", 
	"icarus_head", 
	"icarus_arms", 
	"icarus_body", 
	"icarus_legs", 
	]

func started_game():
	if IGT.in_game_timer <= 0:
		started_fresh_game = true
	started_as = CharacterManager.player_character
	if started_as == "X":
		current_category = categories[3]
	if started_as == "Zero":
		current_category = categories[4]
	if started_as == "Axl":
		current_category = categories[5]
		
	if Configurations.exists("SkipGateway"):
		if Configurations.get("SkipGateway"):
			current_category = categories[0]
			
	if Configurations.exists("ShowDebug"):
		if Configurations.get("ShowDebug"):
			started_fresh_game = false

func _on_player_set():
	
	if started_as != CharacterManager.player_character:
		current_category = categories[0]
		started_as == "-"
		








func _ready() -> void :
	return
#	Event.connect("leaderboard_any", self, "set_category_any")
#	Event.connect("leaderboard_100", self, "set_category_100")
#	Event.connect("leaderboard_x", self, "set_category_x")
#	Event.connect("leaderboard_zero", self, "set_category_zero")
#	Event.connect("leaderboard_axl", self, "set_category_axl")
#
#	Event.connect("player_set", self, "_on_player_set")



func set_category_any():
	current_category = categories[0]
	
func set_category_low():
	current_category = categories[1]
	
func set_category_100():
	current_category = categories[2]
	
func set_category_x():
	current_category = categories[3]
	
func set_category_zero():
	current_category = categories[4]
	
func set_category_axl():
	current_category = categories[5]

func check_for_all_collectibles():
	var total_items = 0.0
	var collected_items = 0.0
	for item in collectibles:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	else:
		return false
	return false

func check_for_x_armors():
	var total_items = 0.0
	var collected_items = 0.0
	for item in x_armors:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	return false

func check_for_category():
	if check_for_all_collectibles() and "black_zero_armor" in GameManager.collectibles and "white_axl_armor" in GameManager.collectibles:
		current_category = categories[2]
	else:
		current_category = categories[0]

	if started_as == "X":
		if check_for_all_collectibles():
			if check_for_x_armors():
				current_category = categories[3]

	if started_as == "Zero":
		if check_for_all_collectibles() and "black_zero_armor" in GameManager.collectibles:
			current_category = categories[4]
			
	if started_as == "Axl":
		if check_for_all_collectibles() and "white_axl_armor" in GameManager.collectibles:
			current_category = categories[5]
			
	if not check_for_all_collectibles() and not "black_zero_armor" in GameManager.collectibles and not "white_axl_armor" in GameManager.collectibles:
		var total_items = 0.0
		var collected_items = 0.0
		for item in x_armors:
			total_items += 1
			if item in GameManager.collectibles:
				collected_items += 1
		if collected_items == 0:
			current_category = categories[1]
			

	if Configurations.exists("SkipGateway"):
		if Configurations.get("SkipGateway"):
			current_category = categories[0]
	if Configurations.exists("ShowDebug"):
		if Configurations.get("ShowDebug"):
			started_fresh_game = false
			
	call_deferred("submit_category")

func submit_category():
	if started_fresh_game:
		CharacterManager.load_user()
		submit_score(CharacterManager.USERNAME, IGT.rta_timer, IGT.in_game_timer, current_category, VERSION)






func submit_score(username, rta, time, category, version):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.connect("request_completed", self, "_on_request_completed")
	var data = {
		"username": username, 
		"rta": rta, 
		"time": time, 
		"category": category, 
		"version": version
	}
	http_request.request(
		server_url + "/add_score", 
		["Content-Type: application/json", "x-api-key: " + API_KEY], 
		true, 
		HTTPClient.METHOD_POST, 
		to_json(data)
	)

func _on_request_completed(result, response_code, headers, body):
	
	

	if response_code == 200:
		var response_data = JSON.parse(body.get_string_from_utf8())
		if response_data.error == OK:
			emit_signal("leaderboard_updated", response_data.result)
		else:
			pass
			
	else:
		pass
		


func get_leaderboard(category):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.connect("request_completed", self, "_on_request_completed")
	
	http_request.request(
		server_url + "/get_leaderboard?category=" + category, 
		["x-api-key: " + API_KEY]
	)
