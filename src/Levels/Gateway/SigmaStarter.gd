extends Area2D
onready var collider: CollisionShape2D = $collisionShape2D
onready var start_portal: Node2D = $"../Portal"

signal x_detected
var started: = false
export  var enable_movement: = false

func activate():
	collider.set_deferred("disabled", false)

func _ready() -> void :
	Event.listen("gameplay_start", self, "check")

func check() -> void :
	if not enable_movement:
		enable_movement = true
		on_SigmaStarter_body_entered()

func _on_SigmaStarter_body_entered(_body: Node) -> void :
	if enable_movement:
		if not started:
			started = true
			emit_signal("x_detected")
			GameManager.player.cutscene_deactivate()
			GameManager.music_player.start_slow_fade_out()
			Tools.timer(1.6, "cutscene_deactivate", GameManager.player)
			start_portal.activate()

func on_SigmaStarter_body_entered() -> void :
	if Configurations.get("SkipGateway") == 1 or GatewayManager.beaten_bosses.size() == 8:
		if enable_movement:
			if not started:
				started = true
				emit_signal("x_detected")
				GameManager.player.cutscene_deactivate()
				GameManager.music_player.start_slow_fade_out()
				Tools.timer(1.6, "cutscene_deactivate", GameManager.player)
				start_portal.activate()

