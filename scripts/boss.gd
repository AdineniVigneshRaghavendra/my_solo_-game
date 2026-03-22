extends CharacterBody2D

@export var health: int = 3

@onready var spot_one = $"../spots/spots1"
@onready var spot_two = $"../spots/spots2"
@onready var spot_three = $"../spots/spots3"
@onready var spot_four = $"../spots/spots4"
@onready var jump_timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_dead: bool = false
var jump_tween: Tween
var spots: Array
var current_spot_index: int = 0
var jump_height: float = 100.0
var started_fight: bool = false

func _ready():
	spots = [spot_one, spot_two, spot_three, spot_four]
	current_spot_index = 0
	global_position = spots[current_spot_index].global_position
	jump_timer.wait_time = 2.0
	jump_timer.one_shot = false  # prevent auto-repeat
	animated_sprite.play("idle")

func _process(_delta):
	if Global.is_in_boss_battle and not started_fight:
		started_fight = true
		jump_timer.start()

func _physics_process(_delta):
	velocity = Vector2.ZERO
	move_and_slide()
	# Force boss back to current spot after any physics push
	if not (jump_tween and jump_tween.is_running()):
		global_position = spots[current_spot_index].global_position

func _on_area_2d_area_entered(area):
	if area.is_in_group("feet"):
		handle_damage(area.get_parent().get_parent())  # removed duplicate player_jump call

func handle_damage(player: CharacterBody2D) -> void:
	if is_dead:
		return

	player.player_jump()  # only called once now
	health -= 1
	$AnimatedSprite2D/AnimationPlayer.play("hurting")

	if health > 0:
		jump_timer.start()  # wait full 2s before jumping, feels fairer
	else:
		die()

func jump():
	if is_dead:
		return

	# Kill any existing tween before starting a new one
	if jump_tween and jump_tween.is_running():
		jump_tween.kill()

	# Pick an adjacent spot (never stay in place)
	var next_spot_options: Array = []
	if current_spot_index == 0:
		next_spot_options = [1]
	elif current_spot_index == spots.size() - 1:
		next_spot_options = [current_spot_index - 1]
	else:
		next_spot_options = [current_spot_index - 1, current_spot_index + 1]

	var random_index: int = next_spot_options[randi() % next_spot_options.size()]
	var target_spot = spots[random_index]

	var start_pos: Vector2 = global_position
	var end_pos: Vector2 = target_spot.global_position

	# Arc jump using two tween steps
	var peak_pos: Vector2 = (start_pos + end_pos) / 2
	peak_pos.y -= jump_height

	jump_tween = create_tween()
	jump_tween.tween_property(self, "global_position", peak_pos, 0.25).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(self, "global_position", end_pos, 0.25).set_ease(Tween.EASE_IN)

	current_spot_index = random_index

func _on_timer_timeout():
	jump()

func die():
	if is_dead:
		return

	is_dead = true
	animated_sprite.play("idle")
	jump_timer.stop()

	if jump_tween and jump_tween.is_running():
		jump_tween.kill()

	call_deferred("_disable_collisions")

	var death_tween: Tween = create_tween()
	death_tween.tween_property(self, "rotation", deg_to_rad(360 * 2), 1.0).set_ease(Tween.EASE_OUT)
	death_tween.tween_callback(queue_free)

	Global.is_in_boss_battle = false
	Global.defeated_boss = true

func _disable_collisions():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
