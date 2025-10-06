extends Node2D

export  var damage: NodePath
onready var dmg = get_node_or_null(damage)

func damage(damage, inflicter) -> float:
	if dmg != null:
		return dmg.damage(damage, inflicter)
	
	return 0.0
