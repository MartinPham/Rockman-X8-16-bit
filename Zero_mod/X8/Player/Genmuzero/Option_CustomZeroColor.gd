extends X8OptionButton


func setup() -> void :
	set_customzerocolor(get_customzerocolor())
	display()

func increase_value() -> void :
	var val = get_customzerocolor()
	val = (val + 1) %10
	set_customzerocolor(val)
	display()

func decrease_value() -> void :
	var val = get_customzerocolor()
	val = (val - 1 + 10) %10
	set_customzerocolor(val)
	display()

func set_customzerocolor(value: int) -> void :
	Configurations.set("CustomZeroColor", value)
	Event.emit_signal("customzerocolor")
	display()

func get_customzerocolor() -> int:
	if Configurations.exists("CustomZeroColor"):
		return Configurations.get("CustomZeroColor")
	return 0

func display() -> void :
	match get_customzerocolor():
		0:
			display_value("NORMAL")
		1:
			display_value("BLACK")
		2:
			display_value("NIGHTMARE")
		3:
			display_value("OMEGA")
		4:
			display_value("ZERO Z")
		5:
			display_value("VIRAL")
		6:
			display_value("VIA")
		7:
			display_value("BETA")
		8:
			display_value("FAKE")
		9:
			display_value("CUSTOM")
