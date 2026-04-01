extends VBoxContainer

func _ready():
	await get_tree().process_frame
	var screen = get_viewport().get_visible_rect().size
	position = (screen - size) / 2
