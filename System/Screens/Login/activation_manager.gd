extends Node

onready var line_edit: LineEdit = $lineEdit
onready var welcome_label: Label = $WelcomeLabel
onready var activation_label: Label = $ActivationLabel
onready var error_label: Label = $ErrorLabel
onready var info: Label = $VersionInfo
onready var fade: Sprite = $fade
onready var tween: TweenController = TweenController.new(self, false)

var check_status_timer: Timer

func fadein() -> void :
	tween.attribute("modulate:a", 0.0, 0.5, fade)

func _ready() -> void :
	fade.modulate = Color.black
	Tools.timer(1.5, "fadein", self)
	info.text = GameManager.current_demo + " V." + GameManager.version
	check_for_username()
	if CharacterManager.USERNAME != "":
		activation_label.text = "Please wait."
		activation_label.show()
		check_validation_status()
	line_edit.connect("text_entered", self, "_on_enter_pressed")

func check_for_username() -> void :
	CharacterManager.load_user()
	if CharacterManager.USERNAME != "":
		activation_label.text = ""
		info.hide()
		activation_label.show()
		welcome_label.hide()
		line_edit.hide()
	else:
		welcome_label.text = "Enter your Username"
		activation_label.hide()
		welcome_label.show()

func _on_enter_pressed(new_text: String) -> void :
	CharacterManager.USERNAME = line_edit.text.strip_edges()
	if CharacterManager.USERNAME == "":
		return
	register_hardware_id()
	error_label.text = "Please wait."
	error_label.show()

func register_hardware_id() -> void :
	var timestamp = FeatureCheck.current_unix_timestamp()
	var nonce = FeatureCheck.generate_nonce()
	var signature = FeatureCheck.generate_auth_signature(FeatureCheck.hardware_id, timestamp, nonce)
	
	var data = {
		"hardware_id": FeatureCheck.hardware_id, 
		"user_name": CharacterManager.USERNAME, 
		"game_version": GameManager.version + GameManager.current_demo, 
		"timestamp": timestamp, 
		"nonce": nonce, 
		"signature": signature
	}

	FeatureCheck.send_authenticated_post_request(
		"/register", data, self, "_on_register_completed"
	)

func _on_register_completed(result, response_code, headers, body) -> void :
	activation_label.hide()
	var body_string = body.get_string_from_utf8()
	var json = JSON.parse(body_string)
	var is_valid_json: bool = false
	var data = {}
	
	if json.error == OK and typeof(json.result) == TYPE_DICTIONARY:
		is_valid_json = true
		data = json.result

	if response_code == 200:
		error_label.hide()
		CharacterManager.save_user(CharacterManager.USERNAME)
		check_for_username()
		call_deferred("check_validation_status")
	else:
		var msg = ""
		if is_valid_json and data.has("message"):
			msg = data["message"]
		else:
			msg = "An unexpected error occurred."
		error_label.show()
		line_edit.text = ""
		error_label.text = msg
		
		match response_code:
			400:
				error_label.text = msg
			403:
				error_label.text = msg
			404:
				error_label.text = msg
			409:
				error_label.text = msg
			405:
				error_label.text = msg
			426:
				error_label.text = msg
			500:
				error_label.text = msg
			0:
				error_label.text = \
				"Server is unreachable!\n\t\t\t\tPlease check your internet connection."
			_:
				error_label.text = "An unexpected error occurred.\n" + str(response_code)

func check_validation_status() -> void :
	var timestamp = FeatureCheck.current_unix_timestamp()
	var nonce = FeatureCheck.generate_nonce()
	var signature = FeatureCheck.generate_auth_signature(FeatureCheck.hardware_id, timestamp, nonce)

	var data = {
		"hardware_id": FeatureCheck.hardware_id, 
		"user_name": CharacterManager.USERNAME, 
		"game_version": GameManager.version + GameManager.current_demo, 
		"timestamp": timestamp, 
		"nonce": nonce, 
		"signature": signature
	}

	FeatureCheck.send_authenticated_post_request(
		"/validate_activation", data, self, "_on_validation_status_received"
	)
	
func _on_validation_status_received(result, response_code, headers, body) -> void :
	var body_string = body.get_string_from_utf8()
	
	var json = JSON.parse(body_string)
	var validated = FeatureCheck.validate_encrypted_response(json)
	var is_valid_json = validated["is_valid"]
	var data = validated["payload"]
	var API_KEY = Encryption.get_api_key()
	
	if is_valid_json and data.has("API_KEY") and data["API_KEY"] == API_KEY:
		if response_code == 200:
			if data.has("is_active") and data["is_active"]:
				if data.has("Event"):
					CharacterManager.CURRENT_EVENT = data["Event"]
				if data.has("Event_message"):
					CharacterManager.EVENT_MESSAGE = data["Event_message"]
				activation_label.hide()
				call_deferred("goto_next_scene")
			else:
				activation_label.text = "Unexpected error occurred"
		else:
			error_label.text = ""
			var msg = ""
			if is_valid_json and data.has("message"):
				msg = data["message"]
			else:
				msg = body_string

			match response_code:
				400:
					activation_label.text = msg
				403:
					activation_label.text = msg
				404:
					activation_label.text = msg
				405:
					activation_label.text = msg
				426:
					activation_label.text = msg
				500:
					activation_label.text = msg
				0:
					activation_label.text = "Server is unreachable!\nPlease check your internet connection."
				_:
					activation_label.text = "An unexpected error occurred.\n" + str(response_code)
	else:
		activation_label.text = "An unexpected error occurred.\n"
		
	API_KEY = ""

func goto_next_scene() -> void :
	CharacterManager.LOGGED_IN = true
	if CharacterManager.CURRENT_EVENT != 0:
		FeatureCheck.download_file("event")
	
	get_tree().change_scene("res://src/Title/DisclaimerScreen.tscn")
