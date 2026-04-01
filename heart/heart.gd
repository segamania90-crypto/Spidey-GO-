extends Area2D

const GRAVITY = 980.0
var velocity_y = 0.0
@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("idle")
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	velocity_y += GRAVITY * delta
	position.y += velocity_y * delta
	
	# останавливаем на уровне пола
	if position.y >= 943:  # высота пола в твоей игре
		position.y = 943
		velocity_y = 0.0
	
	if position.y > 1200:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.health = min(body.health + 90, body.max_health)
		body.update_hp_display()
		$PickupSound.play()
		# скрываем сразу
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		await $PickupSound.finished
		queue_free()
