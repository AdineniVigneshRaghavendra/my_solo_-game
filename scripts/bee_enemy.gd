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

@warning_ignore("unused_parameter")
func _process(delta):
		if Global.game_win == true:
			die()


func _on_area_2d_area_entered(area):
	if area.is_in_group("feet"):
		handle_damage(area.get_parent().get_parent())
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

func handle_damage(damge: CharacterBody2D) -> void:
	if is_dead:
		return
	damge.velocity.y = damge.jump_velocity
	health -= 1
	if health <= 0:
		die()
	
	
func die():
	if is_dead:
		return 
	is_dead = true
	call_deferred("_disabled_collision")
	var death_tween = create_tween()
	death_tween.tween_property(self, "rotation", deg_to_rad(360*10),3.0).set_ease(Tween.EASE_OUT)
	death_tween.tween_callback(queue_free).set_delay(2.0)
	

func _disabled_collision():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
