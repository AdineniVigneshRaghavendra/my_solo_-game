extends Node

var game_over = false
var game_win  =  false
var active_power_up = false
var health = 3
var coins = 0
var is_in_boss_battle = false
var defeated_boss = false

func reset_values():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	game_over = false
	game_win  =  false
	active_power_up = false
	health = 3
	coins = 0
	is_in_boss_battle = false
	defeated_boss = false	


	
