extends X8TextureButton

export  var legible_name: String
export  var description: String

onready var parent: HBoxContainer = get_parent()
onready var name_display: Label = $"../../../../../../Description/name"
onready var disc_display: Label = $"../../../../../../Description/disc"
onready var equip: AudioStreamPlayer = $"../../../../../../../equip"
onready var dark_bg: Sprite = $sprite

onready var grandparent: VBoxContainer = parent.get_parent()
onready var headparts: HBoxContainer = grandparent.get_node("HeadParts")
onready var bodyparts: HBoxContainer = grandparent.get_node("BodyParts")
onready var armsparts: HBoxContainer = grandparent.get_node("ArmsParts")
onready var legsparts: HBoxContainer = grandparent.get_node("LegsParts")
onready var parts = {
	"head": {
		"default": headparts.get_node("head"), 
		"node": headparts, 
	}, 
	"body": {
		"default": bodyparts.get_node("body"), 
		"node": bodyparts, 
	}, 
	"arms": {
		"default": armsparts.get_node("arms"), 
		"node": armsparts, 
	}, 
	"legs": {
		"default": legsparts.get_node("legs"), 
		"node": legsparts, 
	}, 
}

func _on_focus_entered() -> void :
	play_sound()
	display_info()
	flash()
	dark_bg.visible = false

func _on_focus_exited() -> void :
	dark_bg.visible = true
	if name in parent.current_armor:
		return
	else:
		dim()

func on_press() -> void :
	strong_flash()
	Tools.timer(0.075, "play", equip)
	parent.equip(self)

func is_viable_armor(armor_name: String) -> bool:
	return "icarus" in armor_name or "hermes" in armor_name or "ultima" in armor_name

func get_body_part_name(collectible_name: String) -> String:
	return collectible_name.substr(7)

func display_info() -> void :
	name_display.text = tr(legible_name)
	disc_display.text = tr(description)

func visually_unequip_items() -> void :
	pass
