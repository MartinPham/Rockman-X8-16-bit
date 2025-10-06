extends Label

func _ready() -> void :
	text = CharacterManager.USERNAME
	if CharacterManager.USERNAME == "":
		text = "OFFLINE"
