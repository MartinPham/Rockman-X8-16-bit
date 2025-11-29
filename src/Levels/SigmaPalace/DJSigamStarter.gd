extends Area2D

var activated: = false
onready var intro_song: AudioStreamPlayer = $IntroSong
onready var music: AudioStreamPlayer = $"../Music Player"
onready var capsule: CollisionShape2D = $"../Objects/Capsule_Awakened_Zero/area2D/collisionShape2D"
onready var capsule_hide: Node2D = $"../Objects/Capsule_Awakened_Zero"
onready var musicsilencer: CollisionShape2D = $"../Objects/MusicSilencer/collisionShape2D"
onready var musicstarter: CollisionShape2D = $"../Objects/MusicStarter/collisionShape2D"
onready var foreground: ParallaxLayer = $"../parallaxBackground2/foreground"
onready var djsigma: ParallaxLayer = $"../Scenery/parallaxBackground/djsigma"
onready var lights: Node2D = $"../Scenery/lights"
onready var sigmapalace_map: Node2D = $"../Scenery/sigmapalace_map"
onready var finalclouds1: Node2D = $"../Scenery/FinalClouds/clouds"
onready var finalclouds2: Node2D = $"../Scenery/FinalClouds/clouds2"
onready var finalclouds3: Node2D = $"../Scenery/FinalClouds/clouds3"
onready var finalclouds4: Node2D = $"../Scenery/FinalClouds/clouds4"
onready var final_platform: Node2D = $"../Scenery/final_platform"
onready var djsigmagroundmain: TileMap = $"../Scenery/CollisionDJSigma"
onready var djsigmaground: TileMap = $"../Scenery/CollisionDJSigma/CollisionDJSigma"
onready var djsigmaground2: TileMap = $"../Scenery/CollisionDJSigma/CollisionDJSigma2"

func _on_body_entered(_body: Node) -> void :
	if not activated:
		activated = true
		djsigma.visible = true

		foreground.visible = false
		lights.visible = false
		finalclouds1.visible = false
		finalclouds2.visible = false
		finalclouds3.visible = false
		finalclouds4.visible = false
		final_platform.visible = false
		sigmapalace_map.visible = false

		djsigmagroundmain.visible = true
		djsigmaground.visible = false
		djsigmaground2.visible = true

		capsule_hide.position.y += 2000
		capsule.set_deferred("disabled", true)
		musicsilencer.set_deferred("disabled", true)
		musicstarter.set_deferred("disabled", true)

		music.start_fade_out()
		music.volume = -80
		intro_song.loop.stream.loop = true
		intro_song.play()
