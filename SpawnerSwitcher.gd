tool 
extends Node
class_name SpawnerSwitcher

export  var spawner_holders: Array
export  var start: bool = false
export  var switch: bool = false
export  var delete: bool = false

var objects_node: Node2D
var spawners: Array


func _ready() -> void :
	pass
	

func _process(_delta: float) -> void :
	if start:
		get_all_spawners()
		start = false
		
	if switch:
		switch_all_spawners()
		switch = false
		
	if delete:
		delete_all_spawners()
		delete = false

func get_all_spawners() -> void :
	spawners.clear()
	var objects: Array
	for nodepath in spawner_holders:
		objects.append_array(get_node(nodepath).get_children())
	for node in objects:
		if node is Spawner and not "Boss" in node.name and not "Vile" in node.name:
			spawners.append(node)
	

func switch_all_spawners() -> void :
	var i = 0
	for spawner in spawners:
		create_object_in_scene(spawner)
		i += 1
	

func delete_all_spawners() -> void :
	var i = 0
	for spawner in spawners:
		spawner.queue_free()
		i += 1
	

func create_object_in_scene(spawner: Spawner) -> void :
	var enemy: Enemy = spawner.object_to_spawn.instance()
	if spawner.set_direction_to_right:
		enemy.spawn_direction = 1
	else:
		enemy.spawn_direction = - 1
	for key in spawner.custom_vars.keys():
		enemy.set(key, spawner.custom_vars[key])
	spawner.get_parent().add_child(enemy, true)
	enemy.position = spawner.position
	enemy.set_owner(get_tree().edited_scene_root)
