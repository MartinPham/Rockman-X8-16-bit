extends X8OptionButton

export  var legible_name: String
export  var legible_name2: String
export  var description: String
export  var description2: String

onready var equip: AudioStreamPlayer = $"../../../../../../../equip"
onready var unequip: AudioStreamPlayer = $"../../../../../../../unequip"
onready var choice: AudioStreamPlayer = $"../../../../../../../choice"
onready var icon: TextureRect = $"icon"
onready var name_display: Label = $"../../../../../../Description/name"
onready var disc_display: Label = $"../../../../../../Description/disc"
onready var char_name: Label = $"../../../../../../CharacterName"

func _ready() -> void :
	_on_focus_exited()
	icon.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_lock)

func _on_focus_entered() -> void :
	play_sound()
	display_info()
	flash()

func _on_focus_exited() -> void :
	dim()

func on_press() -> void :
	toggle_floppa_axl_lock()
	strong_flash()
	icon.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_lock)

func display_info() -> void :
	name_display.text = tr(legible_name)
	if CharacterManager.floppa_axl_auto_lock:
		disc_display.text = tr(description2)
		name_display.text = tr(legible_name2)
	else:
		disc_display.text = tr(description)
		name_display.text = tr(legible_name)

func process_inputs() -> void :
	pass

func toggle_floppa_axl_lock() -> void :
	CharacterManager.floppa_axl_auto_lock = not CharacterManager.floppa_axl_auto_lock
	if CharacterManager.floppa_axl_auto_lock:
		Tools.timer(0.075, "play", equip)
		disc_display.text = tr(description2)
		name_display.text = tr(legible_name2)
	else:
		Tools.timer(0.075, "play", unequip)
		disc_display.text = tr(description)
		name_display.text = tr(legible_name)
