extends Node

signal features_checked(has_features)

var server_url: String = "https://loginserver.zashiko.online/"
var salt: String = OS.get_unique_id().sha256_text()
var hardware_id: String = (salt + OS.get_unique_id()).sha256_text()

var USER_AGENT_PREFIX: String = "MegamanX8DemakeZashikoMod"
var game_version: String = GameManager.version
var full_user_agent: String = USER_AGENT_PREFIX + GameManager.version

func _ready() -> void :
	connect("features_checked", self, "_on_features_checked")

func validate_encrypted_response(json):
	var result = {
		"is_valid": false, 
		"payload": {}
	}
	if json.error != OK or not json.result.has("iv") or not json.result.has("payload"):
		return result
		
	var decrypted = Encryption.decrypt_sha256_aes_cbc(json.result.iv, json.result.payload)
	if decrypted.has("payload") and decrypted.has("_signature"):
		var payload = decrypted["payload"]
		var signature = decrypted["_signature"]
		if verify_signature(payload, signature):
			result["is_valid"] = true
			result["payload"] = payload
			
	return result

func verify_signature(payload, signature) -> bool:
	var json_payload = Encryption.canonical_json_stringify(payload)
	var SECRET = Encryption.get_secret_key()
	var key = SECRET.to_utf8()
	
	SECRET = ""
	
	var msg = json_payload.to_utf8()
	var hmac = HMACContext.new()
	hmac.start(HashingContext.HASH_SHA256, key)
	hmac.update(msg)
	var result = hmac.finish()
	
	Encryption.secure_wipe_bytes(key)
	Encryption.secure_wipe_bytes(msg)
	
	var hash_hex = result.hex_encode()
	
	Encryption.secure_wipe_bytes(result)
	json_payload = ""
	
	return hash_hex == signature

func generate_nonce() -> String:
	return str(OS.get_ticks_msec()) + "_" + str(randi())

func current_unix_timestamp() -> int:
	return OS.get_unix_time()

func generate_auth_signature(_hardware_id, _timestamp, _nonce) -> String:
	var k = Encryption.get_secret_key()
	var base = _hardware_id + str(_timestamp) + _nonce + k
	k = ""
	return base.sha256_text()

func send_authenticated_post_request(endpoint_path, data, callback_target, callback_method) -> void :
	var API_KEY = Encryption.get_api_key()
	var url = server_url + endpoint_path
	var json_data = JSON.print(data)
	var encrypted = Encryption.encrypt_sha256_aes_cbc(json_data, "_iv", "_payload")
	var encrypted_json = JSON.print({
		"iv": encrypted["_iv"], 
		"payload": encrypted["_payload"]
	})
	var http_request = HTTPRequest.new()
	callback_target.add_child(http_request)

	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + API_KEY, 
		"User-Agent: " + full_user_agent
	]
	API_KEY = ""
	if GameManager.BETA:
		headers.append("x-client-type: BETA")
	else:
		headers.append("x-client-type: PUBLIC")

	http_request.connect("request_completed", callback_target, callback_method)

	var err = http_request.request(url, headers, true, HTTPClient.METHOD_POST, encrypted_json)
	if err != OK:
		pass



























func check_for_features() -> void :
	check_features()

func check_features() -> void :
	var timestamp = current_unix_timestamp()
	var nonce = generate_nonce()
	var signature = generate_auth_signature(hardware_id, timestamp, nonce)

	var data = {
		"hardware_id": hardware_id, 
		"user_name": CharacterManager.USERNAME, 
		"game_version": GameManager.version + GameManager.current_demo, 
		"timestamp": timestamp, 
		"nonce": nonce, 
		"signature": signature
	}

	send_authenticated_post_request(
		"/feature_check", data, self, "_on_features_received"
	)

func _on_features_received(result, response_code, headers, body) -> void :
	var body_string = body.get_string_from_utf8()
	var json = JSON.parse(body_string)
	var validated = validate_encrypted_response(json)
	var is_valid_json = validated["is_valid"]
	var data = validated["payload"]
	
	if is_valid_json:
		if response_code == 200:
			emit_signal("features_checked", data.get("sending_feature", 5))
			return
	
	emit_signal("features_checked", 5)

func _on_features_checked(has_features) -> void :
	
	if has_features < 10:
		CharacterManager.custom_zero_armor = false

	if has_features == 0:
		pass
	
	elif has_features == 1:
		Leaderboard.started_fresh_game = false
		GameManager.collectibles = []
		GlobalVariables.variables = {}
		GameManager.rng.seed = 0
		GatewayManager.reset_bosses()
		IGT.set_time(0.0)
		CharacterManager.game_mode_set = false
		CharacterManager.game_mode = 0
		Savefile.save(Savefile.save_slot)
		CharacterManager._save()
		GameManager.go_to_intro()
		GameManager._ready()
	
	elif has_features == 2:
		Leaderboard.started_fresh_game = false
		GameManager.collectibles = []
		GlobalVariables.variables = {}
		GameManager.rng.seed = 0
		GatewayManager.reset_bosses()
		IGT.set_time(0.0)
		CharacterManager.game_mode_set = false
		CharacterManager.game_mode = 0
		Savefile.save(Savefile.save_slot)
		CharacterManager._save()
		GameManager.go_to_intro()
		GameManager._ready()
	
	elif has_features == 3:
		Leaderboard.started_fresh_game = false
		IGT.set_time(0.0)
		IGT.reset_rta()
		GameManager.go_to_credits()
	
	elif has_features == 4:
		if not CharacterManager.LOGGED_IN:
			Leaderboard.started_fresh_game = false
			IGT.set_time(0.0)
			IGT.reset_rta()
			GameManager.go_to_credits()
	
	elif has_features == 5:
		get_tree().quit()
	
	elif has_features == 10:
		pass
	
	elif has_features == 11:
		pass
	
	else:
		get_tree().quit()

func unlock_features(feature_to_unlock: int = 0):
	var timestamp = current_unix_timestamp()
	var nonce = generate_nonce()
	var signature = generate_auth_signature(hardware_id, timestamp, nonce)

	var data = {
		"hardware_id": hardware_id, 
		"user_name": CharacterManager.USERNAME, 
		"game_version": GameManager.version + GameManager.current_demo, 
		"feature_to_unlock": feature_to_unlock, 
		"timestamp": timestamp, 
		"nonce": nonce, 
		"signature": signature
	}

	send_authenticated_post_request(
		"/feature_unlock", data, self, "_on_features_unlocked"
	)

func _on_features_unlocked(_result, _response_code, _headers, _body) -> void :
	pass




var dlc_name: String = "cache_file"
var dlc_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file(dlc_name)

var download_request: HTTPRequest = HTTPRequest.new()
var dlc_download_complete: bool = false
var beta_download_user_agent: String = "ZASHIKO-DOWNLOAD-BETA"
var public_download_user_agent: String = "ZASHIKO-DOWNLOAD-PUBLIC"
var download_user_agent: String = ""
var download_folder: String = ""

func _get_download_stats() -> void :
	if GameManager.BETA:
		download_user_agent = beta_download_user_agent
		download_folder = "beta"
	else:
		download_user_agent = public_download_user_agent
		download_folder = "public"

func download_dlc() -> void :
	var dir: Directory = Directory.new()
	if not dir.dir_exists(dlc_path.get_base_dir()):
		dir.make_dir_recursive(dlc_path.get_base_dir())
	
	add_child(download_request)
	download_request.connect("request_completed", self, "_on_dlc_download_completed")
	_get_download_stats()
	
	var dlc_url: String = server_url + "download/" + download_folder + "/" + dlc_name
	download_request.download_file = dlc_path
	
	var headers: Array = [
		"User-Agent: " + download_user_agent, 
		"Accept: */*", 
		"Connection: keep-alive", 
		"Accept-Encoding: gzip, deflate"
	]
	var err = download_request.request(dlc_url, headers)
	if err != OK:
		return

func _on_dlc_download_completed(result, response_code, _headers, _body) -> void :
	if result != OK or response_code != 200:
		return
	
	if ProjectSettings.load_resource_pack(dlc_path):
		pass
	
	dlc_download_complete = true
	download_request.queue_free()

func _delete_dlc_file() -> void :
	var dir: Directory = Directory.new()
	if dir.file_exists(dlc_path):
		var _err = dir.remove(dlc_path)

func _notification(what) -> void :
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_delete_dlc_file()
		_delete_downloaded_file("event")

var file_name: String = ""
var file_main_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var file_path: String = file_main_path.plus_file("")
var download_file_request: HTTPRequest = null
var last_downloaded_file: String = ""

func download_file(_file_name) -> void :
	download_file_request = HTTPRequest.new()
	file_name = _file_name
	file_path = file_main_path.plus_file(_file_name)
	var dir: Directory = Directory.new()
	if not dir.dir_exists(file_path.get_base_dir()):
		dir.make_dir_recursive(file_path.get_base_dir())
	
	add_child(download_file_request)
	download_file_request.connect("request_completed", self, "_on_file_download_completed")
	_get_download_stats()
	
	var file_url: String = server_url + "download/" + download_folder + "/" + _file_name
	download_file_request.download_file = file_path
	
	var headers: Array = [
		"User-Agent: " + download_user_agent, 
		"Accept: */*", 
		"Connection: keep-alive", 
		"Accept-Encoding: gzip, deflate"
	]
	var err = download_file_request.request(file_url, headers)
	if err != OK:
		return

func _on_file_download_completed(result, response_code, _headers, _body) -> void :
	if result != OK or response_code != 200:
		return
	
	if ProjectSettings.load_resource_pack(file_path):
		pass
	
	last_downloaded_file = file_name
	download_file_request.queue_free()
	
func _delete_downloaded_file(_name) -> void :
	var dir: = Directory.new()
	if dir.file_exists(file_main_path.plus_file(_name)):
		var _err = dir.remove(file_main_path.plus_file(_name))
