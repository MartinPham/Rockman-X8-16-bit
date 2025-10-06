extends Node2D
class_name Respawner

const respawn_marker: PackedScene = preload("res://src/System/Respawn/RespawnMark.tscn")

export  var active: bool = true
export  var minimum_death_duration: float = 3.0
export  var on_exit_despawn_after: float = 10.0
export  var minimum_exit_duration: float = 0.0
export  var next_checkpoint: int = - 8

var enemies: Array
var starter_enemies: Array
var extras: Array
var deactivated_by_checkpoints: bool = false

signal respawned
signal despawned


func _ready() -> void :
	_initialize_enemies_watched_list()
	despawn_all()
	mark_all_for_respawn()
	Tools.timer(0.1, "first_checkpoint_spawn", self)
	Event.listen("moved_player_to_checkpoint", self, "on_checkpoint_start")

func _initialize_enemies_watched_list() -> void :
	for child in get_children():
		if child is Enemy:
			var watched_enemy = Watched.new(child)
			if child.spawn_at_start:
				starter_enemies.append(watched_enemy)
			else:
				enemies.append(watched_enemy)
		else:
			extras.append(child)

func connect_death_and_screen_signals(enemy: Watched) -> void :
	enemy.object.connect("death", self, "mark_for_respawn", [enemy])
	enemy.object.get_visibility_notifier().connect("screen_exited", self, "on_enemy_exit_screen", [enemy])
	enemy.object.get_visibility_notifier().connect("screen_entered", self, "on_enemy_enter_screen", [enemy])

func on_enemy_exit_screen(enemy: Watched) -> void :
	if is_instance_valid(enemy.object):
		if active and enemy.object.current_health > 0:
			enemy.outside_timer = Tools.timer_r(on_exit_despawn_after, "despawn_and_mark_for_respawn", self, [enemy])

func on_enemy_enter_screen(enemy: Watched) -> void :
	if is_instance_valid(enemy.outside_timer):
		enemy.outside_timer.stop()
		enemy.outside_timer.queue_free()
		enemy.outside_timer = null

func despawn_and_mark_for_respawn(enemy: Watched) -> void :
	if active:
		if is_instance_valid(enemy.object):
			despawn(enemy)
			mark_for_respawn(enemy, minimum_exit_duration)

func despawn(enemy: Watched) -> void :
	if is_instance_valid(enemy.object):
		enemy.object.destroy()
		emit_signal("despawned")

func mark_for_respawn(enemy: Watched, death_duration = minimum_death_duration) -> void :
	if active:
		var mark: = respawn_marker.instance()
		enemy.parent.add_child(mark, true)
		mark.global_position = enemy.position
		mark.rect = enemy.notifier_size
		if death_duration > 0:
			Tools.timer(death_duration, "activate", mark)
		else:
			mark.activate()
		mark.connect("ready_for_respawn", self, "respawn", [enemy])

func respawn(enemy: Watched) -> void :
	if active and not is_instance_valid(enemy.object):
		var spawn = enemy.scene.instance()
		enemy.parent.add_child(spawn, true)
		spawn.global_position = enemy.position
		enemy.object = spawn
		connect_death_and_screen_signals(enemy)
		emit_signal("respawned")
		Event.emit_signal("respawned", spawn)

func activate() -> void :
	active = true

func deactivate() -> void :
	despawn_all()
	destroy_extras()
	active = false

func despawn_all() -> void :
	for each in enemies:
		if is_instance_valid(each.object):
			despawn(each)

func destroy_extras() -> void :
	for each in extras:
		if is_instance_valid(each):
			if "destroy" in each:
				each.destroy()
			else:
				each.queue_free()

func mark_all_for_respawn() -> void :
	for each in enemies:
		mark_for_respawn(each, minimum_death_duration)
	for each in starter_enemies:
		mark_for_respawn(each, minimum_death_duration)

func on_checkpoint_start(checkpoint: CheckpointSettings) -> void :
	if checkpoint.id > next_checkpoint:
		deactivate()
		deactivated_by_checkpoints = true
	elif checkpoint.id == next_checkpoint - 1:
		call_deferred("spawn_starter_enemies")

func first_checkpoint_spawn() -> void :
	if not deactivated_by_checkpoints:
		var checkpoint = 0
		if checkpoint == next_checkpoint - 1:
			call_deferred("spawn_starter_enemies")

func spawn_starter_enemies() -> void :
	for each in starter_enemies:
		respawn(each)

class Watched:
	var object: Enemy
	var position: Vector2
	var parent: Node
	var scene: PackedScene
	var outside_timer: Timer
	var notifier_size: Rect2
	
	func _init(_object: Node2D) -> void :
		object = _object
		position = _object.global_position
		parent = _object.get_parent()
		scene = PackedScene.new()
		notifier_size = _object.get_visibility_notifier().rect
		scene.pack(_object)
