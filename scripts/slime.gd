extends CharacterBody2D

# --- Movement ---
var end_point: Vector2
var start_point: Vector2
var current_target: Vector2

@export var speed: float = 100.0
@export var gravity: float = 900.0

# --- State ---
var is_dead: bool = false
var is_hurt: bool = false

# --- Health ---
@export var slime_health: int = 1


func _ready():
	start_point = global_position
	end_point = $endPoint.global_position
	current_target = end_point
	
	$AnimatedSprite2D.play("default")


func _physics_process(delta):
	if is_dead:
		return
	
	# Apply gravity
	velocity.y += gravity * delta
	
	# Patrol logic
	if global_position.distance_to(current_target) < 2:
		current_target = start_point if current_target == end_point else end_point
	
	var direction = (current_target - global_position).normalized()
	velocity.x = direction.x * speed
	
	# Flip sprite
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = true
	elif direction.x < 0:
		$AnimatedSprite2D.flip_h = false
	
	# Prevent animation override while hurt
	if not is_hurt:
		if $AnimatedSprite2D.animation != "default":
			$AnimatedSprite2D.play("default")
	
	move_and_slide()


@warning_ignore("unused_parameter")
func _process(delta):
	if Global.game_win:
		die()


# --- PLAYER HIT ---
func _on_area_2d_area_entered(area):
	if not area.is_in_group("feet") or is_dead:
		return
	
	# Player bounce
	var player = area.get_parent().get_parent()
	if player.has_method("player_jump"):
		player.player_jump()
	
	# Damage logic
	if slime_health <= 1:
		die()
	else:
		slime_health -= 1
		hurt()


# --- HURT STATE ---
func hurt():
	if is_hurt:
		return
	
	is_hurt = true
	$AnimatedSprite2D.play("hurting")
	
	await $AnimatedSprite2D.animation_finished
	
	if not is_dead:
		is_hurt = false
		$AnimatedSprite2D.play("default")


# --- DEATH ---
func die():
	if is_dead:
		return
	
	is_dead = true
	
	call_deferred("_disable_collisions")
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process(false)
	
	var start_pos = global_position
	var tween = create_tween()
	
	tween.tween_property(self, "global_position", start_pos + Vector2(0, -40), 0.1)
	tween.tween_property(self, "global_position", start_pos + Vector2(0, 1000), 1.0).set_delay(0.1)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(361), 1.2)
	
	tween.tween_callback(queue_free)


# --- DISABLE COLLISIONS ---
func _disable_collisions():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
