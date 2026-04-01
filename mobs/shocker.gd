extends CharacterBody2D

@export var speed = 90.0
@export var health = 3
var gravity = 980.0
var player = null
var is_dying = false
var question_label : Label
var damage_timer = 0.0
var damage_interval = 1.0
var touching_player = false

func _ready():
	
	player = get_tree().get_first_node_in_group("player")
	
	# Знак вопроса
	question_label = Label.new()
	question_label.text = "❗ ❗ ❗"
	question_label.position = Vector2(-20, -180)
	question_label.visible = false
	add_child(question_label)
	
	add_to_group("mob")
	add_to_group("enemies")
	set_collision_layer_value(2, true)   # моб на слое 2
	set_collision_layer_value(1, false)  # убираем с слоя 1
	set_collision_mask_value(1, true)    # видит пол
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)  # моб не толкает паука
	
	# Урон игроку при касании
	$"Affected area".body_entered.connect(_on_player_touched)
	$"Affected area".body_exited.connect(_on_player_left)

func _on_player_touched(body):
	if body.is_in_group("player"):
		if body.is_invincible:
			return
		print("velocity.y паука: ", body.velocity.y)
		print("моб y: ", global_position.y, " паук y: ", body.global_position.y)
		if body.velocity.y > 0 and body.global_position.y < global_position.y:
			print("СТОМП СРАБОТАЛ")
			body.velocity.y = -600
			take_damage(health)
		else:
			body.take_damage(10, global_position)
			
func _on_player_left(body):
	if body.is_in_group("player"):
		touching_player = false

func _physics_process(delta):
	if is_dying:
		return
	
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	
	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if player:
		var direction = player.global_position.x - global_position.x
		var distance = abs(direction)
		
		if distance < 400:
			question_label.visible = true
		else:
			question_label.visible = false
		
		if global_position.y < player.global_position.y - 100:
			velocity.x = 0
		elif direction > 0:
			velocity.x = speed
			$AnimatedSprite2D.animation = "walk right"
		else:
			velocity.x = -speed
			$AnimatedSprite2D.animation = "walk left"
		
		$AnimatedSprite2D.play()
	
	if player and not is_dying:
		var dist = global_position.distance_to(player.global_position)
		if dist < 80:
			damage_timer += delta
			if damage_timer >= damage_interval:
				damage_timer = 0.0
				if not player.is_invincible:
					player.take_damage(10, global_position)
		else:
			damage_timer = 0.0
	
	move_and_slide()

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	$DeathSound.play()
	is_dying = true
	question_label.visible = false
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate", Color(2, 2, 2, 1), 0.2)
	tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1, 0), 0.6)
	tween.tween_callback(queue_free)
