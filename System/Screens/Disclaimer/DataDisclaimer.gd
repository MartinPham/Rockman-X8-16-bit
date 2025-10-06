extends Node2D

onready var scroll_container: ScrollContainer = $scrollContainer
onready var vbox_container: VBoxContainer = scroll_container.get_node("vBoxContainer")
onready var disclaimer_label: RichTextLabel = vbox_container.get_node("disclaimer_text")
onready var accept_button: Button = $accept_button
onready var decline_button: Button = $decline_button
onready var error_label: Label = $error_label
onready var fade: Sprite = $fade
onready var tween: TweenController = TweenController.new(self, false)


func fadein() -> void :
	tween.attribute("modulate:a", 0.0, 0.5, fade)

func _ready() -> void :
	fade.modulate = Color.black
	Tools.timer(0.5, "fadein", self)
	CharacterManager.load_user()
	if CharacterManager.DISCLAIMER_ACCPETED:
		_on_accept_pressed()
		return
	fetch_disclaimer_text()

func fetch_disclaimer_text() -> void :
	var API_KEY: String = Encryption.get_api_key()
	var url: String = FeatureCheck.server_url + "/download/privacy-disclaimer.txt"
	var timestamp: int = FeatureCheck.current_unix_timestamp()
	var nonce: String = FeatureCheck.generate_nonce()
	var signature: String = FeatureCheck.generate_auth_signature(FeatureCheck.hardware_id, timestamp, nonce)
	
	var data: Dictionary = {
		"hardware_id": FeatureCheck.hardware_id, 
		"game_version": GameManager.version + GameManager.current_demo, 
		"timestamp": timestamp, 
		"nonce": nonce, 
		"signature": signature
	}
	
	var json_data: String = JSON.print(data)
	var http_request: HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	
	var headers: Array = [
		"Content-Type: application/json", 
		"x-api-key: " + API_KEY, 
		"User-Agent: " + FeatureCheck.full_user_agent
	]
	API_KEY = ""
	http_request.connect("request_completed", self, "_on_disclaimer_received")
	var err = http_request.request(FeatureCheck.server_url + "/download/privacy-disclaimer.txt", headers, true, HTTPClient.METHOD_GET, json_data)
	if err != OK:
		pass

func _on_disclaimer_received(result, response_code, headers, body) -> void :
	var body_string: String = body.get_string_from_utf8()
	var data = JSON.parse(body_string)
	fade.modulate = Color.black
	Tools.timer(1.5, "fadein", self)
	if response_code == 200:
		var disclaimer_text: String = body.get_string_from_utf8()
		CharacterManager.DISCLAIMER_EU = true
		disclaimer_label.visible = true
		disclaimer_label.bbcode_text = disclaimer_text
		accept_button.visible = true
		decline_button.visible = true
		CharacterManager.load_user()
		if CharacterManager.DISCLAIMER_ACCPETED:
			get_tree().change_scene("res://System/Login/Login Screen.tscn")
			
	elif response_code == 204:
		get_tree().change_scene("res://System/Login/Login Screen.tscn")
		
	else:
		error_label.visible = true
		error_label.text = "An unexpected error occurred. Please try again."
		if body_string != null:
			error_label.text = body_string
		if response_code == 0:
			error_label.text = \
			"Server is unreachable!\n\t\t\tPlease check your internet connection."

func _on_accept_pressed() -> void :
	CharacterManager.DISCLAIMER_ACCPETED = true
	CharacterManager.save_user(CharacterManager.USERNAME)
	get_tree().change_scene("res://System/Screens/Login/Login Screen.tscn")

func _on_decline_button_pressed() -> void :
	get_tree().quit()
