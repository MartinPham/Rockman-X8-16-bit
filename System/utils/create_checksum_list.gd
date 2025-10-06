tool 
extends EditorScript

func _run():
	var files = [
		"res://System/Screens/Disclaimer/DataDisclaimer.gd", 
		"res://System/Screens/Disclaimer/DataDisclaimer.tscn", 
		"res://System/Screens/Login/activation_manager.gd", 
		"res://System/Screens/Login/feature_check.gd", 
		"res://System/Screens/Login/Login Screen.tscn", 
		"res://System/Screens/Login/manager.gd", 
		"res://src/Scripts/GameManager.gd", 
		"res://System/CharacterManager.gd", 
		"res://project.godot", 
		"res://dll_check.dll", 
		"res://task_check.dll"
	]

	var hash_list = {}
	var file: = File.new()
	var hasher: = HashingContext.new()

	for path in files:
		if not file.file_exists(path):
			continue
		file.open(path, File.READ)
		var buffer = file.get_buffer(file.get_len())
		file.close()

		hasher.start(HashingContext.HASH_SHA256)
		hasher.update(buffer)
		var hashed = hasher.finish().hex_encode()
		hash_list[path] = hashed

	var resource: = ConfigFile.new()
	for k in hash_list:
		resource.set_value("checksums", k, hash_list[k])
	resource.save("res://System/utils/checksums.tres")
