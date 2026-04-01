extends Node2D

var heart_scene = preload("res://heart/heart.tscn")
var heart_timer = 0.0
var heart_interval = 25.0  # каждые 25 секунд

var rhino_scene = preload("res://mobs/rhino.tscn")
var scorpion_scene = preload("res://mobs/scorpion.tscn")
var lizard_scene = preload("res://mobs/the_lizard.tscn")
var shocker_scene = preload("res://mobs/shocker.tscn")
var powler_scene = preload("res://mobs/powler.tscn")

var spawn_points = [-900, -600, -300, 0, 300, 600, 900, 1200, 1500, 1800, 2100, 2400, 2600]

func _ready():
	var hud = $Buttons/Control
	var player = $"Spider man"
	print("HUD: ", hud)
	print("Player: ", player)
	player.setup_hud(hud)
	
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.autostart = true
	timer.timeout.connect(_spawn_mob)
	add_child(timer)

func _spawn_mob():
	var mobs = [rhino_scene, scorpion_scene, lizard_scene, shocker_scene, powler_scene]
	var random_mob = mobs[randi() % mobs.size()]
	
	var spawn_x
	if randi() % 2 == 0:
		spawn_x = -1500  # за левой стеной
	else:
		spawn_x = 3200   # за правой стеной
	
	var mob = random_mob.instantiate()
	add_child(mob)
	mob.global_position = Vector2(spawn_x, 943)
	
func _process(delta):
	heart_timer += delta
	if heart_timer >= heart_interval:
		heart_timer = 0.0
		spawn_heart()
		
func spawn_heart():
	var heart = heart_scene.instantiate()
	heart.position = Vector2(spawn_points.pick_random(), -100)
	add_child(heart)
