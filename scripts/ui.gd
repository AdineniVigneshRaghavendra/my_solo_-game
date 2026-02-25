extends Node2D

@onready var level_one = preload("res://scenes/main.tscn")
@onready var level_two = preload("res://scenes/main.tscn")
@onready var level_three = preload("res://scenes/main.tscn")

func _ready():
	$menu.visible = true
	$inGame.visible = false
	$Gameover.visible = false
	$Gamewin.visible = false

func _process(_delta):
	if Global.game_win == true:
		$menu.visible = false
		$inGame.visible = false
		$Gameover.visible = false
		$Gamewin.visible = true
	if Global.game_lose == true:
		$menu.visible = false
		$inGame.visible = false
		$Gameover.visible = true
		$Gamewin.visible = false
	
	$inGame/textcounter/Label.text = str(Global.coins)
	$Gamewin/LabelCoins.text = "Coins: "+ str(Global.coins)

	update_current_hearts()

func update_current_hearts():
	if Global.health >=3:
		Global.health=3
		$"inGame/hearts/normal hearts/h1".visible = true
		$"inGame/hearts/normal hearts/h2".visible = true
		$"inGame/hearts/normal hearts/h3".visible = true
	elif Global.health == 2:
		$"inGame/hearts/normal hearts/h1".visible = true
		$"inGame/hearts/normal hearts/h2".visible = true
		$"inGame/hearts/normal hearts/h3".visible = false
	elif Global.health == 1:
		$"inGame/hearts/normal hearts/h1".visible = true
		$"inGame/hearts/normal hearts/h2".visible = false
		$"inGame/hearts/normal hearts/h3".visible = false
	elif Global.health == 0:
		$"inGame/hearts/normal hearts/h1".visible = false
		$"inGame/hearts/normal hearts/h2".visible = false
		$"inGame/hearts/normal hearts/h3".visible = false
		
	if Global.active_power_up == true:
		$"inGame/hearts/power hearts".visible = true
	else:
		$"inGame/hearts/power hearts".visible = false


func _on_buttonmute_pressed():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	


func _on_buttonlevel_1_pressed():
	$menu.visible = false
	$inGame.visible = true
	var new_level = level_one.instantiate()
	add_sibling(new_level)
	
	
	


func _on_buttonlevel_2_pressed():
	$menu.visible = false
	$inGame.visible = true
	var new_level = level_two.instantiate()
	add_sibling(new_level)
	


func _on_buttonlevel_3_pressed():
	$menu.visible = false
	$inGame.visible = true
	var new_level = level_three.instantiate()
	add_sibling(new_level)
	


func _on_buttonmenu_pressed():
	Global.rest_values()
	get_tree().reload_current_scene()
	
