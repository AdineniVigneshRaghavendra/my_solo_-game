extends CharacterBody2D

var end_point
var start_point

var current_target: Vector2
var speed = 100.0
var gravity = 900.0

var is_dead = false
@export var slime_health = 1

func _ready():
	$AnimatedSprite2D.play("default")
	end_point = $endPoint.global_position
	start_point = self.global_position
	current_target = end_point

func _physics_process(delta):
	velocity.y += gravity * delta
	
	if global_position.distance_to(current_target) < 5:
		if current_target == end_point:
			current_target = start_point
		else:
			current_target = end_point
	
	var direction = (current_target - global_position).normalized()
	velocity.x = direction.x * speed
	
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif direction.x < 0 :
		$AnimatedSprite2D.flip_h = false
		
	move_and_slide()
	
func _process(delta):
	if Global.game_win == true:
		die()



func _on_area_2d_area_entered(area):
	if area.is_in_group("feet"):
		area.get_parent().get_parent().player_jump()
		if slime_health <= 1:
			die()
		else:
			slime_health -= 1
			$AnimatedSprite2D/AnimationPlayer.play("hurting")

func die():
	if is_dead == true:
		return
	is_dead = true
	
	call_deferred("_disabled_collisions")
	
	velocity = Vector2.ZERO
	
	set_physics_process(false)
	set_process(false)
	
	var death_tween = create_tween()
	
	death_tween.tween_property(self, "global_position", global_position + Vector2(0, -40), 0.1).set_ease(Tween.EASE_OUT)
	death_tween.tween_property(self, "global_position", global_position + Vector2(0, 1000), 1.0).set_ease(Tween.EASE_IN).set_delay(0.1)
	death_tween.parallel().tween_property(self, "rotation", deg_to_rad(360 + 1), 1.2).set_ease(Tween.EASE_OUT_IN)
	death_tween.tween_callback(queue_free)

func _disabled_collisions():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
