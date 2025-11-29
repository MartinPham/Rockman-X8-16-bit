extends TouchScreenButton

export  var _action: String

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("pressed", self, "_on_button_pressed")
	connect("released", self, "_on_button_released")

func _on_button_pressed() -> void :
	Input.action_press("jump")
	Input.action_press("dash")
	self.modulate.a = 1.0

func _on_button_released() -> void :
	Input.action_release("jump")
	Input.action_release("dash")
	self.modulate.a = 0.5
