extends X8OptionButton

onready var deactivated_sprite = get_node("deactivated")

func _ready() -> void :
	_on_focus_exited()
	if CharacterManager.extra_saber_03:
		deactivated_sprite.hide()
	else:
		deactivated_sprite.show()

func _on_focus_entered() -> void :
	play_sound()
	flash()

func _on_focus_exited() -> void :
	dim()

func on_press() -> void :
	play_sound()
	toggle_extra_color()
	Savefile.call_deferred("save", Savefile.save_slot)

func process_inputs() -> void :
	pass

func toggle_extra_color() -> void :
	CharacterManager.extra_saber_03 = not CharacterManager.extra_saber_03
	if CharacterManager.extra_saber_03:
		deactivated_sprite.hide()
	else:
		deactivated_sprite.show()
