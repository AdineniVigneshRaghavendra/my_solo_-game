extends CharacterBody2D

@export var start_position: Vector2
@export var end_position: Vector2
@export var speed: float = 100.0

var direction: int = 1

func _ready():
	start_position =  self.global_position
	end_position = $endPoint2.global_position
	$AnimatedSprite2D.play("default")
	
@warning_ignore("unused_parameter")
func _physics_process(delta):
	var target_y = end_position.y if direction == 1 else start_position.y
	
	velocity.x = 0
	
	global_position.y = move_toward(
		global_position.y,
		target_y,
		speed * delta
	)
	
	if abs(global_position.y - target_y) < 1:
		direction *= -1
