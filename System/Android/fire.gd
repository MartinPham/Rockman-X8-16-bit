extends TouchScreenButton

export  var _action: String

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	Event.listen("ridearmor_activate", self, "controlhide")
	Event.listen("ridearmor_deactivate", self, "controlshow")
	connect("pressed", self, "_on_button_pressed")
	connect("released", self, "_on_button_released")

func _on_button_pressed() -> void :
	Input.action_press(_action)
	self.modulate.a = 1.0

func _on_button_released() -> void :
	Input.action_release(_action)
	self.modulate.a = 0.5

func controlhide():
	Input.action_release(_action)
	self.modulate.a = 0
	$".".visible = false

func controlshow():
	self.modulate.a = 0.5
	$".".visible = true
