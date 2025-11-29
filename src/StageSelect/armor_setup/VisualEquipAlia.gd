extends HBoxContainer

onready var part_options: = get_children()
onready var default_part = part_options[0]
onready var armor: Control = $"../../../Armor"
onready var tween: TweenController = TweenController.new(self, false)
onready var menu: CanvasLayer = $"../../../../../.."

var current_armor: Array


func _ready() -> void :
	var _s = menu.connect("initialize", self, "initialize")

func initialize() -> void :
	show_parts()
	for part in part_options:
		part._on_focus_exited()

func show_parts() -> void :
	default_part.visible = true

func filter_parts(all_armor: Array) -> Array:
	var currently_equipped_pieces: = []
	var body_parts_with_armor = []
	var i: = all_armor.size() - 1
	
	while i >= 0:
		var body_part = get_body_part_name(all_armor[i])
		if not body_part in body_parts_with_armor:
			currently_equipped_pieces.append(all_armor[i])
			body_parts_with_armor.append(body_part)
		i -= 1
	
	if currently_equipped_pieces.size() < 4:
		var n = ["head", "arms", "body", "legs"]
		for exception in n:
			if not exception in body_parts_with_armor:
				GameManager.add_equip_exception(exception)
				
	return currently_equipped_pieces

func emit_current_set_signals() -> void :
	var parts = 0
	Event.emit_signal("mixed_set")
	

func equip(part: X8TextureButton) -> void :
	for option in part_options:
		if option != part:
			option.dim()
	visual_armor_unequip(get_body_part_name(part.name))
	visual_armor_equip(part.name)

func visual_armor_equip(part_name: String, reset: bool = true) -> void :
	if reset:
		tween.end()
		tween.reset()
	var piece: TextureRect = armor.get_node(part_name)
	var original_y: = piece.rect_position.y
	var duration: = 0.15
	piece.visible = true
	piece.rect_position.y -= 7
	piece.modulate.a = 0.0
	tween.create(Tween.EASE_IN, Tween.TRANS_QUAD, true)
	tween.add_attribute("modulate:a", 1.0, duration, piece)
	tween.add_attribute("rect_position:y", original_y + 3, duration, piece)
	tween.set_sequential()
	tween.add_callback("flash", self, [piece])
	tween.add_attribute("rect_position:y", original_y - 1, 0.06, piece)
	tween.add_attribute("rect_position:y", original_y, 0.06, piece)

func visual_armor_unequip(body_area: String) -> void :
	for kids in armor.get_children():
		if body_area in kids.name:
			kids.visible = false

func flash(piece: TextureRect) -> void :
	piece.modulate = Color(5, 5, 5, 1)
	tween.create(Tween.EASE_OUT, Tween.TRANS_CUBIC, true)
	tween.add_attribute("modulate", Color.white, 0.3, piece)

func align(part_name: String = "none") -> void :
	alignment = BoxContainer.ALIGN_CENTER

func get_body_part_name(collectible_name: String) -> String:
	if collectible_name.length() <= 4:
		return collectible_name
	return collectible_name.substr(7)

func is_in_exceptions(armor_name: String) -> bool:
	if get_body_part_name(armor_name) in GameManager.equip_exceptions:
		return true
	return false
