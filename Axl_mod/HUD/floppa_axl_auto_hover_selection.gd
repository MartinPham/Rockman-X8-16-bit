extends X8OptionButton

export  var legible_name: String
export  var description: String

onready var equip: AudioStreamPlayer = $"../../../../../../../equip"
onready var unequip: AudioStreamPlayer = $"../../../../../../../unequip"
onready var choice: AudioStreamPlayer = $"../../../../../../../choice"
onready var icon: TextureRect = $"icon"
onready var name_display: Label = $"../../../../../../Description/name"
onready var disc_display: Label = $"../../../../../../Description/disc"
onready var char_name: Label = $"../../../../../../CharacterName"

func _ready() -> void :
	_on_focus_exited()
	icon.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_hover)

func _on_focus_entered() -> void :
	play_sound()
	display_info()
	flash()

func _on_focus_exited() -> void :
	dim()

func on_press() -> void :
	toggle_floppa_axl_hover()
	strong_flash()
	icon.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_hover)

func display_info() -> void :
	name_display.text = tr(legible_name)
	disc_display.text = tr(description)

func process_inputs() -> void :
	pass

func toggle_floppa_axl_hover() -> void :
	CharacterManager.floppa_axl_auto_hover = not CharacterManager.floppa_axl_auto_hover
	if CharacterManager.floppa_axl_auto_hover:
		Tools.timer(0.075, "play", equip)
	else:
		Tools.timer(0.075, "play", unequip)
