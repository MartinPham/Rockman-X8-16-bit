extends X8OptionButton

export  var legible_name: String
export  var description: String

onready var equip: AudioStreamPlayer = $"../../../../../equip"
onready var unequip: AudioStreamPlayer = $"../../../../../unequip"
onready var choice: AudioStreamPlayer = $"../../../../../choice"
onready var icon: TextureRect = $"icon"
onready var name_display: Label = $"../../../../Description/name"
onready var disc_display: Label = $"../../../../Description/disc"
onready var char_name: Label = $"../../../../CharacterName"


func setup() -> void :
	pass

func _on_focus_entered() -> void :
	._on_focus_entered()
	display_info()

func on_press() -> void :
	pass

func process_inputs() -> void :
	pass

func display_info() -> void :
	name_display.text = tr(legible_name)
	disc_display.text = tr(description)
