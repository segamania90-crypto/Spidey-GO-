extends Area2D

var speed = 600.0
var direction = 1
var trail = []
var timer = 0.0

func _ready():
	print("ПАУТИНА СОЗДАНА! direction=", direction)
	set_process(true)
	var shape = CircleShape2D.new()
	shape.radius = 10
	$CollisionShape2D.shape = shape
	# Отключаем коллизию на старте чтобы не задеть паука
	$CollisionShape2D.disabled = true
	body_entered.connect(_on_body_entered)
	# Включаем коллизию через 0.2 секунды
	await get_tree().create_timer(0.2).timeout
	if is_inside_tree():
		$CollisionShape2D.disabled = false
		set_collision_mask_value(2, true)  # видит мобов на layer 2

func _process(delta):
	timer += delta
	if timer > 3.0:
		queue_free()
		return
	position.x += speed * direction * delta
	print("позиция: ", position)
	trail.append(global_position)
	if trail.size() > 8:
		trail.pop_front()
	queue_redraw()

func _draw():
	for i in range(trail.size()):
		var local_pos = to_local(trail[i])
		var alpha = float(i) / trail.size()
		var radius = lerp(2.0, 6.0, alpha)
		draw_circle(local_pos, radius, Color(1, 1, 1, alpha * 0.6))
	draw_circle(Vector2.ZERO, 10, Color(1, 1, 1, 1))
	draw_circle(Vector2(-3, -3), 3, Color(1, 1, 1, 0.8))

func _on_body_entered(body):
	print("ПАУТИНА ПОПАЛА В: ", body.name)
	if body.is_in_group("enemies"):
		body.die()
	queue_free()
