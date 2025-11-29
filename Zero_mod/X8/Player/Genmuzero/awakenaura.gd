extends Node2D

onready var awakenaura: AnimatedSprite = $"../animatedSprite/awakenaura"
onready var riden_awakenaura: AnimatedSprite = $ridenawakenaura

export  var active: bool = false
export  var shield_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Rasetsusen_Hitbox.tscn")

onready var character = get_parent()
onready var deflect_sound = $deflect

var current_hitbox = null
var hitbox_name: String = "Fan Shield"
var hitbox_radius: float = 32
var hitbox_inner_radius: float = 0
var hitbox_upleft_corner: Vector2 = Vector2( - hitbox_radius, - hitbox_radius)
var hitbox_downright_corner: Vector2 = Vector2(hitbox_radius, hitbox_radius)
var hitbox_upgraded: bool = false
var hitbox_canhit: bool = false
var hitbox_spawn_effect: bool = false
var deflectable: bool = true
var deflectable_type: int = 0
var only_deflect_weak: bool = true


func _ready() -> void :
	character.listen("zero_health", self, "deactivate")
	Event.connect("player_death", self, "deactivate")
	Event.listen("character_switch", self, "deactivate")
	Event.listen("character_switch_end", self, "check")
	Event.listen("beamin", self, "check")
	Event.listen("beamout", self, "deactivate")
	Event.listen("ridearmor_activate", self, "riden_activate")
	Event.listen("ridearmor_deactivate", self, "riden_deactivate")
	Event.listen("customzerocolor", self, "reload_color")
	Event.listen("character_switch", self, "reload_color")
	Event.listen("character_switch_end", self, "reload_color")
	check()

signal ridearmor_deactivate

func check() -> void :
	if CharacterManager.player_character == "Zero":
		if CharacterManager.awakened_zero_armor:
			activate()
	elif CharacterManager.player_character == "X" or \
	CharacterManager.player_character == "Pallette" or \
	CharacterManager.player_character == "Alia" or \
	CharacterManager.player_character == "Layer" or \
	CharacterManager.player_character == "Axl":
		deactivate()

func activate() -> void :
	active = true
	set_physics_process(true)
	awakenaura.show()

func deactivate() -> void :
	active = false
	set_physics_process(false)
	awakenaura.hide()

func riden_activate() -> void :
	if CharacterManager.player_character == "Zero":
		if CharacterManager.awakened_zero_armor:
			riden_awakenaura.show()

func riden_deactivate() -> void :
	if CharacterManager.player_character == "Zero":
		if CharacterManager.awakened_zero_armor:
			riden_awakenaura.hide()

func reload_color() -> void :
	if CharacterManager.player_character == "Zero":
		if is_instance_valid(GameManager.player):
			var zero = GameManager.player
			CharacterManager.set_zeroX8_colors(zero.animatedSprite)
			zero.animatedSprite.get_node("afterImages").set_shader_colors()
			CharacterManager.set_saberX8_colors(zero.animatedSprite)

func _physics_process(_delta: float) -> void :
	if active:
		hitbox_radius = 32
		hitbox_upleft_corner = Vector2( - hitbox_radius, - hitbox_radius)
		hitbox_downright_corner = Vector2(hitbox_radius, hitbox_radius)
		spawn_shield(Vector2(0, - 6), hitbox_upleft_corner, hitbox_downright_corner)
		

func spawn_shield(_position: Vector2, _hitbox_upleft: Vector2, _hitbox_downright: Vector2) -> void :
	current_hitbox = shield_hitbox.instance()
	add_child(current_hitbox)
	
	var size = _hitbox_downright - _hitbox_upleft
	var radius = min(size.x, size.y) / 2

	current_hitbox.set_hitbox(_position, radius)
	current_hitbox.name = hitbox_name
	current_hitbox.damage = 0
	current_hitbox.damage_to_bosses = 0
	current_hitbox.damage_to_weakness = 0
	current_hitbox.break_guard_damage = 0
	current_hitbox.break_guards = false
	current_hitbox.saber_rehit = 0
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.inner_radius = hitbox_inner_radius
	current_hitbox.canhit = hitbox_canhit
	current_hitbox.spawn_effect = hitbox_spawn_effect
	current_hitbox.deflectable = deflectable
	current_hitbox.deflectable_type = deflectable_type
	current_hitbox.only_deflect_weak = only_deflect_weak
	current_hitbox.remove_from_group("Player Projectile")
