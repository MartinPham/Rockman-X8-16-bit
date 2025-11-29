extends X8TextureButton

export  var weapon_resource: Resource

onready var weapon_name: Label = get_node("weapon_name")
onready var ammo: TextureProgress = get_node("ammo/current")
onready var layer_icon = $"../../Lives/Layer_icon"
onready var layer_base: Texture = preload("res://Zero_mod/HUD/Layer_base.png")
onready var layer_bfan: Texture = preload("res://Zero_mod/HUD/Layer_fan.png")
onready var layer_dglaive: Texture = preload("res://Zero_mod/HUD/Layer_glaive.png")
onready var layer_kknuckle: Texture = preload("res://Zero_mod/HUD/Layer_knuckle.png")
onready var layer_tbreaker: Texture = preload("res://Zero_mod/HUD/Layer_breaker.png")
onready var layer_sigmablade: Texture = preload("res://Zero_mod/HUD/Layer_sigmablade.png")

var character_name = "Layer"
var weapon


func _ready() -> void :
	call_deferred("set_player_weapon")
	var _s = menu.connect("pause_starting", self, "on_start")
	if weapon_resource:
		weapon_name.text = tr(weapon_resource.short_name)
		texture_normal = weapon_resource.icon
		pass

func on_start() -> void :
	pass

func set_pause_icon(_weapon) -> void :
	if not _weapon:
		layer_icon.texture = layer_base
	else:
		if weapon.name == "B-Fan":
			layer_icon.texture = layer_bfan
		if weapon.name == "D-Glaive":
			layer_icon.texture = layer_dglaive
		if weapon.name == "K-Knuckle":
			layer_icon.texture = layer_kknuckle
		if weapon.name == "T-Breaker":
			layer_icon.texture = layer_tbreaker
		if weapon.name == "Sigma-Blade":
			layer_icon.texture = layer_sigmablade

func set_player_weapon() -> void :
	if weapon_resource and GameManager.player:
		var i = CharacterManager.team.find(character_name)
		for _weapon in GameManager.team[i].get_node("Shot").get_children():
			if _weapon is ZeroSpecialWeapon:
				if _weapon.weapon.collectible == weapon_resource.collectible:
					weapon = _weapon

func _on_focus_entered() -> void :
	._on_focus_entered()
	if CharacterManager.player_character != "Layer":
		return
	if GameManager.is_player_in_scene():
		var _shot_node = GameManager.player.get_node("Shot")
		if _shot_node != null:
			var _animation = _shot_node.get_parent().get_animation()
			if _animation in _shot_node.get_parent().saber_animations:
				return
			_shot_node.set_current_weapon(weapon)
	get_parent().set_weapon(self)
	set_pause_icon(weapon)

func _on_focus_exited() -> void :
	if get_parent().choosen_weapon != self:
		._on_focus_exited()

func on_press() -> void :
	pass
