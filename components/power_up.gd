extends CharacterBody2D

var gravity = 1200
var just_spawned = true

func _ready():
	# Wait one physics frame before enabling movement
	await get_tree().physics_frame
	just_spawned = false

func _physics_process(delta):
	if just_spawned:
		return
	
	velocity.y += gravity * delta
	move_and_slide()
