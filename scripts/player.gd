extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -800.0
@export var gravity: float = 1400.0

@onready var player_sprite: AnimatedSprite2D = $body/AnimatedSprite2D
@onready var player_sprite_powered_up: AnimatedSprite2D = $body/AnimatedSprite2DPowerup
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var camera: Camera2D = $Camera2D
@onready var hurting_anim: AnimationPlayer = $body/AnimationPlayerhurting

var hurting = false
var in_enemy = false
var game_ended = false
var powered_up = false

func _ready():
	player_sprite.play("idle")
	
func _physics_process(delta):
	if Global.game_over != true:
		if not is_on_floor():
			velocity.y += gravity * delta
		if Global.game_win == true:
			player_sprite.play("idle")
			player_sprite_powered_up.play("idle")
			return
		
		if Input.is_action_just_pressed("ui_accept") and is_on_floor() == true:
			player_jump()
		
		var direction: float = Input.get_axis("ui_left","ui_right")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x,0, speed)
		
		update_animations()
		move_and_slide()
		
func player_jump():
	if is_on_floor():
		if not $sounds/Sfxjump.is_playing():
			$sounds/Sfxjump.play()
			velocity.y = jump_velocity
	 
func update_animations():
	var landing_soon: bool = ray_cast_2d.is_colliding() and velocity.y > 0
	
	if landing_soon or is_on_floor():
		if velocity.x != 0:
			player_sprite.play("walking")
		else:
			player_sprite.play("idle")
	elif velocity.y < 0:
		player_sprite.play("inairup")
	elif velocity.y > 0:
		player_sprite.play("inairdown")
	
	if velocity.x > 0:
		player_sprite.flip_h = false
		player_sprite_powered_up.flip_h = false
	elif velocity.x < 0:
		player_sprite.flip_h = true
		player_sprite_powered_up.flip_h = true
	
@warning_ignore("unused_parameter")
func _process(delta):
	if Global.health <= 0:
		end_game()
	if in_enemy == true and hurting == false:
		player_hit()
	
	if powered_up == true:
		Global.active_power_up = true
		player_sprite = player_sprite_powered_up
		speed = 400.0
		$body/AnimatedSprite2D.visible = false
		player_sprite.visible = true
	else:
		Global.active_power_up = false
		player_sprite = $body/AnimatedSprite2D
		speed = 300.0
		player_sprite.visible = true
		player_sprite_powered_up.visible = false
	
func player_hit():
	$sounds/SfxBump.play()
	powered_up = false
	hurting = true
	hurting_anim.play("hurting")
	$Camera2D.shake()
	$TimerHurting.start()
	Global.health -= 1
	
func end_game():
	Global.game_over = true
	powered_up = false 
	player_sprite = $body/AnimatedSprite2D
	hurting_anim.play("idle")
	player_sprite.play("gameover")
	if game_ended == false:
		$sounds/SfxHurt.play()
		call_deferred("_disabled_collisions")
		$effects/AnimationPlayer.play("end")
		game_ended = true
	return 
func _disabled_collisions():
	$CollisionShape2D.disabled = true
	$areas/Area2DHitBox/CollisionShape2D.disabled = true
	

func _on_area_2d_hit_box_body_entered(body):
	if body.is_in_group("enemy"):
		in_enemy = true
		if hurting == false and game_ended == false:
			player_hit()
	if body.is_in_group("powerup"):
		$sounds/SfxGem.play()
		body.queue_free()
		Global.health += 3
		powered_up = true 

func _on_timer_hurting_timeout() -> void:
	hurting = false
	hurting_anim.play("idle")
	
	

func _on_area_2d_hit_box_body_exited(body):
	if body.is_in_group("enemy"):
		in_enemy = false

func _on_area_2d_hit_box_area_entered(area):
	if area.is_in_group("win"):
		Global.game_win = true
	if area.is_in_group("coin"):
		$sounds/SfxCoin.play()
		area.get_parent().queue_free()
		Global.coins += 1
	if area.is_in_group("heart"):
		$sounds/SfxGem.play()
		area.get_parent().queue_free()
		Global.health += 1
	if area.is_in_group("spikes"):
		end_game()
	if area.is_in_group("bossFight"):
		Global.is_in_boss_battle = true
		area.queue_free()
	if area.is_in_group("leaveFight"):
		area.queue_free()
		
			
		
	
