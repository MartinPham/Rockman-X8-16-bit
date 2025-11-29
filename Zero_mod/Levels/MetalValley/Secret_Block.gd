extends KinematicBody2D

onready var blocking_wall: CollisionShape2D = $collisionShape2D
onready var blocking_wall2: CollisionShape2D = $collisionShape2D2
onready var blocking_wall3: CollisionShape2D = $collisionShape2D3
onready var blocking_wall4: CollisionShape2D = $collisionShape2D4
onready var animatedSprite: AnimatedSprite = $animatedSprite
onready var remains: Particles2D = $Remains / remains_particles
onready var remains_texture: Texture = preload("res://Zero_mod/Levels/MetalValley/remains_Wall.png")

var unlocked: bool = false

func _ready() -> void :
	animatedSprite.animation = "Locked"
	blocking_wall4.set_deferred("disabled", true)

func _on_area2D_body_entered(body: Node) -> void :
	if not unlocked:
		if body.is_in_group("Player Projectile"):
			if "Juuhazan_Charged_B" in body.name:
				unlock_secret()
				unlocked = true

func unlock_secret() -> void :
	remains.texture = remains_texture
	remains.emitting = true
	blocking_wall.set_deferred("disabled", true)
	blocking_wall2.set_deferred("disabled", true)
	blocking_wall3.set_deferred("disabled", true)
	blocking_wall4.set_deferred("disabled", false)
	animatedSprite.animation = "Unlocked"
