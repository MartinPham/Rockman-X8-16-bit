extends CanvasLayer

onready var leaderboard_container = $Menu / LeaderboardContainer
onready var username_container = $Menu / LeaderboardContainer / Username
onready var time_container = $Menu / LeaderboardContainer / Time
onready var rta_container = $Menu / LeaderboardContainer / RTA
onready var shadow_container = $Menu / LeaderboardContainerShadow
onready var username_shadow_container = $Menu / LeaderboardContainerShadow / Username
onready var rta_shadow_container = $Menu / LeaderboardContainerShadow / RTA
onready var time_shadow_container = $Menu / LeaderboardContainerShadow / Time

onready var tabs_container = $Menu / TabsContainer
var active_tab: Control = null

onready var cat_script = preload("res://System/Screens/Leaderboard/Category_Load.gd")

var font = preload("res://src/Fonts/x8_bitmapfont.tres")
var font_leaderboard = preload("res://src/Fonts/Xclassicfont.fnt")
var font_color = Color("#68caff")
var font_color_sel = Color("#fbffaf")
var font_color_dim = Color(0.8, 0.8, 0.8)
var tab_bg = preload("res://System/Screens/Leaderboard/Category.PNG")

var categories = ["any%", "low%", "100%", "x%", "zero%", "axl%"]
var version = Leaderboard.VERSION

var category_containers = {}
var tab_labels = []

func fetch_leaderboard(category: String) -> void :
	var url = Leaderboard.server_url + "/get_leaderboard?category=" + category + "&version=" + version
	var http_request = HTTPRequest.new()

	add_child(http_request)

	
	var err = http_request.request(
		url, 
		["x-api-key: " + Leaderboard.API_KEY]
	)

	if err != OK:
		pass
	else:
		http_request.connect("request_completed", self, "_on_request_completed", [category, http_request])

func _on_request_completed(result: int, response_code: int, headers: Array, body: PoolByteArray, category: String, http_request: HTTPRequest) -> void :
	if response_code == 200:
		var body_string = body.get_string_from_utf8()

		var json_data = JSON.parse(body_string)

		if json_data.error != OK:
			return
		
		var leaderboard = json_data.result.leaderboard
		

		var container = category_containers[category]

		for i in range(1, username_shadow_container.get_child_count()):
			username_shadow_container.get_child(i).queue_free()
		for i in range(1, rta_shadow_container.get_child_count()):
			rta_shadow_container.get_child(i).queue_free()
		for i in range(1, time_shadow_container.get_child_count()):
			time_shadow_container.get_child(i).queue_free()
			
		for i in range(1, username_container.get_child_count()):
			username_container.get_child(i).queue_free()
		for i in range(1, rta_container.get_child_count()):
			rta_container.get_child(i).queue_free()
		for i in range(1, time_container.get_child_count()):
			time_container.get_child(i).queue_free()

		for entry in leaderboard:
			var username = entry.username
			username = username.substr(0, 13)
			var time = IGT.time_formatting(entry.time)
			var rta = IGT.time_formatting(entry.rta)

			var username_label_shadow = Label.new()
			username_label_shadow.text = username
			username_label_shadow.add_font_override("font", font)
			username_label_shadow.add_color_override("font_color", Color(0, 0, 0))
			username_label_shadow.align = Label.ALIGN_LEFT
			username_label_shadow.valign = Label.VALIGN_CENTER

			var rta_label_shadow = Label.new()
			rta_label_shadow.text = str(rta)
			rta_label_shadow.add_font_override("font", font)
			rta_label_shadow.add_color_override("font_color", Color(0, 0, 0))
			rta_label_shadow.align = Label.ALIGN_CENTER
			rta_label_shadow.valign = Label.VALIGN_CENTER

			var time_label_shadow = Label.new()
			time_label_shadow.text = str(time)
			time_label_shadow.add_font_override("font", font)
			time_label_shadow.add_color_override("font_color", Color(0, 0, 0))
			time_label_shadow.align = Label.ALIGN_CENTER
			time_label_shadow.valign = Label.VALIGN_CENTER

			username_shadow_container.add_child(username_label_shadow)
			rta_shadow_container.add_child(rta_label_shadow)
			time_shadow_container.add_child(time_label_shadow)

			var username_label = Label.new()
			username_label.text = username
			username_label.add_font_override("font", font)
			username_label.align = Label.ALIGN_LEFT
			username_label.valign = Label.VALIGN_CENTER
			
			var rta_label = Label.new()
			rta_label.text = str(rta)
			rta_label.add_font_override("font", font)
			rta_label.align = Label.ALIGN_CENTER
			rta_label.valign = Label.VALIGN_CENTER
			
			var time_label = Label.new()
			time_label.text = str(time)
			time_label.add_font_override("font", font)
			time_label.align = Label.ALIGN_CENTER
			time_label.valign = Label.VALIGN_CENTER

			username_container.add_child(username_label)
			rta_container.add_child(rta_label)
			time_container.add_child(time_label)

	else:
		pass


func _ready() -> void :
	return
#	if get_parent().name == "root":
#		start()
#	else:
#		menu.visible = false
#		visible = true
#
#
#	for i in range(categories.size()):
#		var category = categories[i]
#		var tab_button = X8TextureButton.new()
#		tab_button.rect_min_size = Vector2(64, 25)
#		tab_button.rect_position = Vector2(0, 0)
#		tab_button.margin_right = 1
#		tab_button.margin_right = 65
#
#		var tab_label_shadow = Label.new()
#		tab_label_shadow.text = category
#		tab_label_shadow.add_font_override("font", font)
#		tab_label_shadow.add_color_override("font_color", Color(0, 0, 0))
#		tab_label_shadow.rect_position = Vector2(1, 9)
#		tab_label_shadow.align = Label.ALIGN_CENTER
#		tab_label_shadow.valign = Label.VALIGN_CENTER
#		tab_label_shadow.rect_min_size = Vector2(66, 17)
#		var tab_label = Label.new()
#		tab_label.text = category
#		tab_label.add_font_override("font", font)
#		tab_label.add_color_override("font_color", font_color_dim)
#		tab_label.rect_position = Vector2(0, 8)
#		tab_label.align = Label.ALIGN_CENTER
#		tab_label.valign = Label.VALIGN_CENTER
#		tab_label.rect_min_size = Vector2(66, 17)
#
#		tab_button.add_child(tab_label_shadow)
#		tab_button.add_child(tab_label)
#		tabs_container.add_child(tab_button)
#
#		tab_button.set_script(cat_script)
#		tab_button.category_num = i
#		tab_button.texture_normal = tab_bg
#		tab_button.modulate = Color("#7d7d7d")
#		tab_button.action_mode = TextureButton.ACTION_MODE_BUTTON_PRESS
#		tab_button.focus_mode = TextureButton.FOCUS_ALL
#		tab_button.menu_path = tab_button.get_parent().get_parent().get_parent().get_path()
#		tab_button.connect("pressed", tab_button, "_on_pressed")
#		tab_button.connect("focus_entered", tab_button, "_on_focus_entered")
#		tab_button.connect("focus_exited", tab_button, "_on_focus_exited")
#		tab_button.connect("mouse_entered", tab_button, "_on_mouse_entered")
#		tab_button.connect("mouse_exited", tab_button, "_on_mouse_exited")
#		tab_button.start_button()
#
#		var category_container = VBoxContainer.new()
#		leaderboard_container.add_child(category_container)
#
#		category_containers[category] = category_container
#
#
#
#
#
#		if i == 0:
#			active_tab = tab_label
#			active_tab.add_color_override("font_color", font_color)
#
#	if categories.size() > 0:
#		fetch_leaderboard(categories[0])

func _on_tab_pressed(event, category: String, tab_label: Label) -> void :
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if active_tab:
			active_tab.add_color_override("font_color", font_color_dim)
		active_tab = tab_label
		active_tab.add_color_override("font_color", font_color)
		equip.play()
		fetch_leaderboard(category)
		for container in category_containers.values():
			container.visible = false
		category_containers[category].visible = true

func _on_tab_hover(tab_label: Label) -> void :
	if tab_label != active_tab:
		tab_label.add_color_override("font_color", Color(1, 1, 1))
	choice.play()

func _on_tab_exit(tab_label: Label) -> void :
	if tab_label != active_tab:
		tab_label.add_color_override("font_color", font_color_dim)


var active: = false

export  var menu_path: NodePath
export  var initial_focus: NodePath
export  var exit_action: = "none"
export  var start_emit_event: = "none"

onready var menu: Control = get_node(menu_path)
onready var focus: Control = get_node(initial_focus)
onready var fader: ColorRect = $Fader
onready var choice: AudioStreamPlayer = $choice
onready var equip: AudioStreamPlayer = $equip
onready var pick: AudioStreamPlayer = $pick

var locked: = true

signal initialize
signal start
signal end
signal lock_buttons
signal unlock_buttons

var highlighted_index = 0

func _input(event: InputEvent) -> void :
	if active:
		if exit_action != "none" and event.is_action_pressed(exit_action):
			end()

func start() -> void :
	emit_signal("initialize")
	active = true
	emit_signal("lock_buttons")
	if start_emit_event != "none":
		Event.emit_signal(start_emit_event)
	fader.visible = true
	fader.FadeIn()
	yield(fader, "finished")
	unlock_buttons()
	emit_signal("start")
	call_deferred("give_focus")

func give_focus() -> void :
	focus.silent = true
	focus.grab_focus()

func end() -> void :
	lock_buttons()
	fader.FadeOut()
	yield(fader, "finished")
	emit_signal("end")
	active = false
	
func play_choice_sound() -> void :
	choice.play()

func button_call(method, param = null) -> void :
	if param:
		call_deferred(method, param)
	else:
		call(method)
	
func lock_buttons() -> void :
	emit_signal("lock_buttons")
	locked = true
	
func unlock_buttons() -> void :
	emit_signal("unlock_buttons")
	locked = false
