extends CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -900.0
const GRAVITY = 1200.0
var is_attacking = false
var is_dead = false
var move_direction = 0
var web_scene: PackedScene = preload("res://spider_man/web.tscn")
@onready var sprite = $AnimatedSprite2D

# HP
var health = 100
var max_health = 100
var is_invincible = false
var hp_label = null

func _ready():
	add_to_group("player")
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)   # паук на слое 3
	set_collision_mask_value(1, true)    # видит пол
	set_collision_mask_value(3, true)    # видит стены
	set_collision_mask_value(2, false)   # не толкает мобов
	hp_label = get_tree().get_first_node_in_group("hp_label")
	update_hp_display()
	

func _physics_process(delta):
	if is_dead:
		return
	
	# прыжок ВСЕГДА работает
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# атака ВСЕГДА работает
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	if not is_invincible:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction == 0:
			direction = move_direction
		velocity.x = direction * SPEED
		update_animation(direction)
	
	move_and_slide()  # ← вынеси сюда!
	
	
func setup_hud(hud):
	hud.move_left_pressed.connect(func(): move_direction = -1)
	hud.move_left_released.connect(func(): move_direction = 0)
	hud.move_right_pressed.connect(func(): move_direction = 1)
	hud.move_right_released.connect(func(): move_direction = 0)
	hud.jump_pressed.connect(func():
		if is_on_floor(): 
			velocity.y = JUMP_VELOCITY
			$JumpSound.play()
	)
	hud.attack_pressed.connect(func(): attack())

func update_animation(direction):
	if is_attacking:
		return
	if direction > 0:
		sprite.flip_h = true
	elif direction < 0:
		sprite.flip_h = false
	if not is_on_floor():
		sprite.play("jump")
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func attack():
	if is_attacking:
		return
	is_attacking = true
	sprite.play("attack")
	$WebSound.play()
	if web_scene:
		var web = web_scene.instantiate()
		get_tree().current_scene.add_child(web)
		if sprite.flip_h:
			web.direction = 1
		else:
			web.direction = -1
		web.global_position = global_position + Vector2(30 * web.direction, 15)
	await sprite.animation_finished
	is_attacking = false

func take_damage(amount, enemy_position = Vector2.ZERO):
	if is_invincible or is_dead:
		return
	health -= amount
	health = max(health, 0)
	update_hp_display()
	is_invincible = true
	
	$DamageSound.play()
	
	# Мигание красным
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(2, 0, 0, 1), 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.tween_property(sprite, "modulate", Color(2, 0, 0, 1), 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	
	# Отлёт от врага
	var direction = sign(global_position.x - enemy_position.x)
	velocity.y = -250
	velocity.x = direction * 400
	
	await get_tree().create_timer(0.5).timeout
	is_invincible = false
	if health <= 0:
		die()

func update_hp_display():
	if hp_label:
		hp_label.text = "❤️ " + str(health)

func die():
	if is_dead:
		return
	is_dead = true
	sprite.play("death")
	$DeathSound.play()
	await sprite.animation_finished
	# Переход на главное меню
	get_tree().change_scene_to_file("res://main menu/main_menu.tscn")
