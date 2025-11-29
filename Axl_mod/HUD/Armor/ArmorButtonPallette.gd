extends X8TextureButton

export  var legible_name: String
export  var description: String

onready var parent: = get_parent()
onready var name_display: Label = $"../../../../../../Description/name"
onready var disc_display: Label = $"../../../../../../Description/disc"
onready var equip: AudioStreamPlayer = $"../../../../../../../equip"
onready var dark_bg: Sprite = $sprite

onready var part_types: = ["HeadParts", "BodyParts", "ArmParts", "LegParts"]
onready var part_nodes: = {
	"HeadParts": get_part_node("HeadParts"), 
	"BodyParts": get_part_node("BodyParts"), 
	"ArmParts": get_part_node("ArmParts"), 
	"LegParts": get_part_node("LegParts"), 
}
onready var default_parts: = get_parts_by_name("head", "body", "arms", "legs")

func get_part_node(name: String) -> Node:
	return get_parent().get_parent().get_node(name)

func get_parts_by_name(h: String, b: String, a: String, l: String) -> Dictionary:
	return {
		"HeadParts": part_nodes["HeadParts"].get_node(h), 
		"BodyParts": part_nodes["BodyParts"].get_node(b), 
		"ArmParts": part_nodes["ArmParts"].get_node(a), 
		"LegParts": part_nodes["LegParts"].get_node(l), 
	}

func equip_parts(parts: Dictionary) -> void :
	for part_type in part_types:
		var node = parts[part_type]
		node.strong_flash()
		part_nodes[part_type].equip(node)

func _on_focus_entered() -> void :
	play_sound()
	display_info()
	flash()
	dark_bg.visible = false

func _on_focus_exited() -> void :
	dark_bg.visible = true
	dim()

func on_press() -> void :
	strong_flash()
	Tools.timer(0.075, "play", equip)
	parent.equip(self)

func display_info() -> void :
	name_display.text = tr(legible_name)
	disc_display.text = tr(description)

func visually_unequip_items() -> void :
	pass
