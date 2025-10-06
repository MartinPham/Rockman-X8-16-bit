tool 
extends EditorScript

func _run() -> void :
	save_to()
	

func save_to():
	var img = get_scene().root.get_viewport().get_texture().get_data()
	img.flip_y()
	return img.save_png("e:/screenshots/screenshot.png")
