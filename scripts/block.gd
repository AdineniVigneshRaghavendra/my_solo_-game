extends CharacterBody2D

var is_destroyed := false
@export var is_power_block := false
@onready var power_node = preload("res://components/power_up.tscn")

func _on_area_2d_area_entered(area):
	if area.is_in_group("head") and not is_destroyed:
		is_destroyed = true
		
		if is_power_block:
			call_deferred("_spawn_power_up")
		
		queue_free()   # remove block immediately

func _spawn_power_up():
	var new_power = power_node.instantiate()
	get_tree().current_scene.add_child(new_power)

	new_power.global_position = global_position 
	is_power_block = false
	
func destroy():
	call_deferred("_disabled_collisions")
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process(false)
	
	var explode_tween = create_tween()
	explode_tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_OUT)
	explode_tween.tween_property(self, "scale", Vector2(0, 0), 0.2).set_ease(Tween.EASE_IN).set_delay(0.1)
	explode_tween.tween_callback(queue_free)

func _disabled_collisions():
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true
