extends AnimatedSprite
onready var start_portal: Node2D = $"../StartPortal"
onready var start_portal4: Node2D = $"../StartPortal4"
onready var StartEntrance4: AnimatedSprite = $"../StartEntrance4"


func _ready() -> void :
	if GameManager.has_beaten_the_game():
		visible = true
		play("default")
		start_portal.activate()
		start_portal4.activate()
		StartEntrance4.show()
	pass
