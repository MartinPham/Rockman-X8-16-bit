extends Area2D

var activated: = false
onready var next_limit: Area2D = $"../../Limits/vile2"
onready var djsigma_song: AudioStreamPlayer = $"../../DJSigmaStarter/IntroSong"
onready var music: AudioStreamPlayer = $"../../Music Player"
onready var foreground: ParallaxLayer = $"../../parallaxBackground2/foreground"

func _on_body_entered(_body: Node) -> void :
	if not activated:
		activated = true
		foreground.visible = false
		music.start_fade_out()
		djsigma_song.fade_out()
		djsigma_song.volume_db = -80
		djsigma_song.base_volume = -80
		GameManager.player.cutscene_deactivate()
		GameManager.camera.update_area_limits(next_limit)
		GameManager.camera.start_door_translate(next_limit.global_position, next_limit, false)
