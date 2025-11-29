extends X8OptionButton

func setup() -> void :
	set_touchenable(get_touchenable())
	display()

func increase_value() -> void :
	set_touchenable( not get_touchenable())
	display()

func decrease_value() -> void :
	set_touchenable( not get_touchenable())
	display()

func set_touchenable(value: bool) -> void :
	Configurations.set("TouchEnable", value)
	Event.emit_signal("touchcontrol")
	display()

func get_touchenable():
	if Configurations.exists("TouchEnable"):
		return Configurations.get("TouchEnable")
	return false

func display():
	if get_touchenable():
		display_value("SHOW_VALUE")
	else:
		display_value("HIDE_VALUE")
