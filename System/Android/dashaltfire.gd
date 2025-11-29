extends TouchScreenButton

export  var _action: String

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("pressed", self, "_on_button_pressed")
	connect("released", self, "_on_button_released")

func _on_button_pressed() -> void :
	Input.action_press("dash")
	yield(get_tree().create_timer(0.001), "timeout")
	print()
	Input.action_press("alt_fire")
	self.modulate.a = 1.0


func _on_button_released() -> void :
	Input.action_release("dash")
	Input.action_release("alt_fire")
	self.modulate.a = 0.5

