extends Camera2D

@export var shake_amplitude: float = 10.0
@export var shake_duratin: float = 0.2
var tween: Tween

func shake() -> void:
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var start_offset: Vector2 = Vector2.ZERO
	var end_offset: Vector2 = Vector2(
		randf_range(-shake_amplitude, shake_amplitude),
		randf_range(-shake_amplitude, shake_amplitude)
	)
	
	tween.tween_property(self, "offset", end_offset, shake_duratin / 2)
	tween.tween_property(self, "offset", start_offset, shake_duratin / 2)
	
func _process(delta):
	if Global.is_in_boss_battle == true:
		var boss_view = get_tree().get_first_node_in_group("bossView")
		position_smoothing_enabled = false
		global_position = boss_view.global_position
	if Global.defeated_boss == true:
		Global.is_in_boss_battle = false
		position = Vector2(-1, -99)
		Global.defeated_boss = true
		position_smoothing_enabled = true
