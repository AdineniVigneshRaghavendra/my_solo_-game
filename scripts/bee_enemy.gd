extends CharacterBody2D

@export var speed: float = 150.0
@export var health: int = 1
@export var gravity: float = 1800.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $Area2DDetection

var is_dead: bool = false
var player_in_range: bool = false
var player: CharacterBody2D

func _ready():
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	if not is_dead:
		handle_movent()
	else:
		velocity.y += gravity * delta
	move_and_slide()
	
	func _process(delta):
		if Global.game_win == true:
			die()


func _on_area_2d_area_entered(area):
	if area.is_in_group("feet"):
		handle(area.get_parent().get_parent())
		area.get_parent().get_parent().player_jump()
		


func _on_area_2d_detection_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player = body




func _on_area_2d_detection_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player = null

func handle_movent():
	if player_in_range == true and player:
		var target_position: Vector2 = player.global_position
		var direction: Vector2 = (target_position - global_position).normalized()
		velocity = direction * speed
		sprite.flip_h = velocity.x > 0
	else:
		velocity = Vector2.ZERO

func ha

	
