extends Node2D

func _ready():
	ProjectSettings.load_resource_pack("res://Sounds.pck")
	ProjectSettings.load_resource_pack("res://Sounds-OST-Intro.pck")
	ProjectSettings.load_resource_pack("res://Sounds-OST-Loop1.pck")
	ProjectSettings.load_resource_pack("res://Sounds-OST-Loop2.pck")
	ProjectSettings.load_resource_pack("res://SFX.pck")
	ProjectSettings.load_resource_pack("res://AltMusic.pck")
	get_tree().change_scene("res://src/Title/DisclaimerScreen.tscn")
