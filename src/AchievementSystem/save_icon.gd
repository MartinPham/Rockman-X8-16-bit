extends TextureRect

onready var tween: TweenController = TweenController.new(self, false)


func _ready() -> void :
	Savefile.connect("saved", self, "display")
	modulate.a = 0.0

func display() -> void :
	tween.reset()
	tween.attribute("modulate:a", 0.5, 0.1)
	tween.add_attribute("modulate:a", 0, 0.75)
