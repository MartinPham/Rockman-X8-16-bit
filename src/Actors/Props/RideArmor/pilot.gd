extends AnimatedMirror

onready var reference_frames: Resource = preload("res://src/Actors/Props/RideArmor/pilot_sprites/ra_x.res")
onready var x_ride: Texture = preload("res://src/Actors/Props/RideArmor/pilot_sprites/ra_x.png")
onready var x_ultimate_ride: Texture = preload("res://X_mod/UltimateX/Sprites/ra_x_ultimate.png")
onready var zero_ride: Texture = preload("res://Zero_mod/X8/Sprites/Ride/ride_zero.png")
onready var axl_ride: Texture = preload("res://Axl_mod/Player/Sprites/Ride/ride_axl.png")
onready var alia_ride: Texture = preload("res://src/Actors/Player/alia_sprites/ride_alia.png")
onready var layer_ride: Texture = preload("res://Zero_mod/X8/LayerSprites/Ride/ride_layer.png")
onready var pallette_ride: Texture = preload("res://Axl_mod/Player/PalletteSprites/Ride/ride_pallette.png")

func set_player_sprite_sheet():
	var _texture = x_ride
	material = GameManager.player.animatedSprite.material
	match CharacterManager.player_character:
		"Player":
			_texture = x_ride
		"X":
			_texture = x_ride
			if CharacterManager.ultimate_x_armor:
				_texture = x_ultimate_ride
		"Zero":
			_texture = zero_ride
		"Axl":
			_texture = axl_ride
		"Alia":
			_texture = alia_ride
		"Layer":
			_texture = layer_ride
		"Pallette":
			_texture = pallette_ride
	self.frames = CharacterManager.update_texture_with_new_size(_texture, reference_frames)

func _ready() -> void :
	Event.connect("character_switch", self, "set_player_sprite_sheet")
	set_player_sprite_sheet()
	material = GameManager.player.animatedSprite.material
