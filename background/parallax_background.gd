extends ParallaxBackground

var speed = 100  # скорость движения фона

func _process(delta):
	scroll_offset.x -= speed * delta
