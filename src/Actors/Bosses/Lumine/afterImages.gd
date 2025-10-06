extends Node

const subtle_motion: Array = [Vector2(1, 1), Vector2( - 1, - 1), Vector2(1, - 1), Vector2( - 1, 1), Vector2(0, 0)]

export  var active: bool = false
export  var frequency: float = 0.1
export  var duration: float = 0.5
export  var initial_color: Color = Color.white
export  var final_color: Color = Color(1, 1, 1, 0)
export  var motion_amount: float = 0.0

onready var original: AnimatedSprite = $".."

var current_motion: = 0


func _ready() -> void :
	if active:
		active = true
		afterimage_emit()

func activate():
	if not active:
		active = true
		afterimage_emit()

func deactivate():
	active = false

func afterimage_emit():
	if active:
		var afterimage: = AnimatedSprite.new()
		add_child(afterimage)
		equate_settings(afterimage)
		fade_and_delete(afterimage)
		Tools.timer(frequency, "afterimage_emit", self)

func fade_and_delete(afterimage: AnimatedSprite) -> void :
	afterimage.modulate = initial_color
	var tween: = afterimage.create_tween().set_parallel(true)
	tween.tween_property(afterimage, "modulate", final_color, duration)
	tween.tween_property(afterimage, "position", afterimage.position + get_motion(), duration)
	tween.set_parallel(false)
	tween.tween_callback(afterimage, "queue_free")

func equate_settings(afterimage: AnimatedSprite) -> void :
	afterimage.scale = original.scale
	afterimage.frames = original.frames
	afterimage.animation = original.animation
	afterimage.frame = original.frame
	afterimage.playing = false
	afterimage.centered = original.centered
	afterimage.offset = original.offset
	afterimage.flip_h = original.flip_h
	afterimage.flip_v = original.flip_v
	afterimage.z_index = 1
	afterimage.global_position = original.global_position

func get_motion() -> Vector2:
	current_motion += 1
	if current_motion > subtle_motion.size() - 1:
		current_motion = 0
	return subtle_motion[current_motion] * motion_amount
