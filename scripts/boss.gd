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
var started_fight = false

func _ready():
	spots = [spot_one, spot_two, spot_three, spot_four]
	jump_timer.wait_time = 2.0
	animated_sprite.play("idle")

@warning_ignore("unused_parameter")
func _process(delta):
	if Global.is_in_boss_battle == true and started_fight == false:
		started_fight = true
		jump_timer.start()
	

func _on_area_2d_area_entered(area):
	if area.is_in_group("feet"):
		area.get_parent().get_parent().player_jump()
		handle_damage(area.get_parent().get_parent())
		
func handle_damage(damage: CharacterBody2D) -> void:
	if is_dead == true:
		return
	damage.velocity.y = damage.jump_velocity
	health -= 1
	$AnimatedSprite2D/AnimationPlayer.play("hurting")
	if health >  0:
		jump_timer.start()
		jump()
	else:
		die()

func jump():
	if is_dead == true:
		return
	
	if jump_tween and jump_tween.is_running():
		jump_tween.kill()
	
	var next_spot_instance = []
	if current_spot_index == 0:
		next_spot_instance = [1]
	elif current_spot_index == spots.size() - 1:
		next_spot_instance = [spots.size() - 1]
	else:
		next_spot_instance = [current_spot_index - 1, current_spot_index + 1]
		
	var random_index = next_spot_instance[randi() % next_spot_instance.size()]
	
	var target_spot = spots[random_index]
	var start_pos = global_position
	var end_pos = target_spot.global_position
	
	jump_tween = create_tween()
	
	var peak_pos = (start_pos + end_pos) / 2
	peak_pos.y -= jump_height
	
	jump_tween.tween_property(self, "global_position", peak_pos, 0.25).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(self, "global_position", end_pos, 0.25).set_ease(Tween.EASE_IN)
	
	current_spot_index = random_index



func _on_timer_timeout():
	jump()

func die():
	if is_dead:
		return
	$AnimatedSprite2D/AnimationPlayer.play("idle")
	is_dead = true
	jump_timer.stop()
	
	if jump_tween and jump_tween.is_running():
		jump_tween.kill()
		
	call_deferred("_disabled_collisions")
	
	var death_tween = create_tween()
	
	death_tween.tween_property(self, "rotation", deg_to_rad(360*2), 1.0).set_ease(Tween.EASE_OUT)
	death_tween.tween_callback(queue_free)
	Global.is_in_boss_battle = false
	Global.defeated_boss = true
	
	
func _disabled_collisions():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
		
