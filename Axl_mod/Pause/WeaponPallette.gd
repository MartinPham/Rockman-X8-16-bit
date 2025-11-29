extends X8TextureButton

export  var weapon_resource: Resource

onready var weapon_name: Label = get_node("weapon_name")
onready var ammo: TextureProgress = get_node("ammo/current")

onready var base_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_base.png")
onready var raygun_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_raygun.png")
onready var sprial_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_spiralmagnum.png")
onready var blacka_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_blackarrow.png")
onready var plasma_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_plasmagun.png")
onready var blastl_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_blastlauncher.png")
onready var boundb_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_boundblaster.png")
onready var icegat_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_icegattling.png")
onready var flameb_texture: Texture = preload("res://Axl_mod/HUD/Pause/Pallette_flameburner.png")

var character_name = "Pallette"
var weapon


func _ready() -> void :
	call_deferred("set_player_weapon")
	var _s = menu.connect("pause_starting", self, "on_start")
	if weapon_resource:
		weapon_name.text = tr(weapon_resource.short_name)
		texture_normal = weapon_resource.icon

func on_start() -> void :
	ammo.value = get_bar_value()

func get_bar_value() -> float:
	if weapon:
		return inverse_lerp(0.0, weapon.max_ammo, weapon.current_ammo) * 28
	return 28.0

func set_pause_icon(_weapon) -> void :
	var _pallette_icon = get_parent().get_parent().get_node("Lives").get_node("Pallette_icon")
	if _pallette_icon != null:
		if not _weapon:
			_pallette_icon.texture = base_texture
		else:
			if weapon.name == "RayGun":
				_pallette_icon.texture = raygun_texture
			elif weapon.name == "SpiralMagnum":
				_pallette_icon.texture = sprial_texture
			elif weapon.name == "BlackArrow":
				_pallette_icon.texture = blacka_texture
			elif weapon.name == "PlasmaGun":
				_pallette_icon.texture = plasma_texture
			elif weapon.name == "BlastLauncher":
				_pallette_icon.texture = blastl_texture
			elif weapon.name == "BoundBlaster":
				_pallette_icon.texture = boundb_texture
			elif weapon.name == "IceGattling":
				_pallette_icon.texture = icegat_texture
			elif weapon.name == "FlameBurner":
				_pallette_icon.texture = flameb_texture

func set_player_weapon() -> void :
	if weapon_resource and GameManager.player:
		var i = CharacterManager.team.find(character_name)
		for _weapon in GameManager.team[i].get_node("Shot").get_children():
			if _weapon is WeaponBossAxl or _weapon.name == "GigaCrash" or _weapon.name == "XDrive":
				if _weapon.weapon.collectible == weapon_resource.collectible:
					weapon = _weapon

func _on_focus_entered() -> void :
	._on_focus_entered()
	if CharacterManager.player_character != "Pallette":
		return
	if GameManager.is_player_in_scene():
		var _shot_node = GameManager.player.get_node("Shot")
		if _shot_node != null:
			_shot_node.set_current_weapon(weapon)
	get_parent().set_weapon(self)
	set_pause_icon(weapon)

func _on_focus_exited() -> void :
	if get_parent().choosen_weapon != self:
		._on_focus_exited()

func on_press() -> void :
	pass
