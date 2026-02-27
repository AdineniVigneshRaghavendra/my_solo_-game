extends CharacterBody2D

var is_destroyed = false
@export var is_power_block = false
@onready var power_node = preload("res://components/power_block.tscn")


func _on_area_2d_area_entered(area):
	if area.is_in_group("head"):
		if is_power_block == true:
			call_deferred("_spawn_power_up")
		destroy()

func _spawn_power_up():
	var new_power = power_node.instantiate()
