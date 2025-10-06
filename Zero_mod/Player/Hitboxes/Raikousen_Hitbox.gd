extends SaberZeroHitbox
class_name RaikousenZeroHitbox

const bypass_shield: bool = true

onready var pause_script: Script = preload("res://Zero_mod/System/PauseInstance.gd")
onready var tracker: Area2D = $tracker
onready var tracker_collision: CollisionShape2D = $tracker / collisionShape2D
onready var light: Light2D = $light

var pause_duration: float = 0.3
var instant_damage: bool = false
var light_color: Color = Color("#63C6EF")
var light_size: Vector2 = Vector2(3, 2)
var target: Node2D


func is_invulnerable() -> bool:
	return true

func _physics_process(delta: float) -> void :
	light.light(0.5 * rand_range(0.9, 1.5), Vector2(light_size.x * rand_range(1.0, 1.7), light_size.y * rand_range(0.9, 1.3)), light_color)
	target = tracker.get_closest_target()
	if target:
		if "Lamp" in target.name:
			target.energize()
	

func set_hitbox_corners(upleft: Vector2, downright: Vector2) -> void :
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	collision_shape.shape = shape
	deflection_shape.shape = shape
	tracker_collision.shape = shape
	position = (upleft + downright) / 2
	light.position = position

func hit(target) -> void :
	pause_duration = 0.2
	if active:
		
		if saber_rehit != 0:
			if "saber_rehit" in target:
				
				if target.saber_rehit <= 0:
					if target is BossDamage:
						Event.emit_signal("saber_has_hit_boss")
						target.damage(damage, self)
					elif target is DamageReceiver:
						target.damage(damage, self)
					else:
						if instant_damage:
							target.damage(damage, self)
						else:
							var existing_pause_node = target.get_parent().get_node_or_null("Pause Enemy")
							if existing_pause_node != null:
								existing_pause_node._set_pause_timer(pause_duration)
								existing_pause_node.damage += damage
								
							else:
								var pause_node = Node.new()
								pause_node.set_name("Pause Enemy")
								pause_node.set_script(pause_script)
								pause_node.pause_duration = pause_duration
								pause_node.stun = true
								target.get_parent().add_child(pause_node)
								pause_node.start_pause(target.get_parent(), damage, self)
					
					target.saber_rehit = saber_rehit
					Event.emit_signal("saber_has_hit")
					show_damage_values()

func deflect_projectile(body) -> void :
	if body.is_in_group("Enemy Projectile"):
		if body.has_method("_OnHit"):
			body._OnHit(self)
			return
		body.destroy()
