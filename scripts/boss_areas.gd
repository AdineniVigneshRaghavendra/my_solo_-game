extends Node2D

@warning_ignore("unused_parameter")
func _process(delta):
	if Global.is_in_boss_battle == true:
		$TileMapLayerWalls.visible = true
		$TileMapLayerWalls.collision_enabled = true
	else:
		$TileMapLayerWalls.visible = false
		$TileMapLayerWalls.collision_enabled = false
