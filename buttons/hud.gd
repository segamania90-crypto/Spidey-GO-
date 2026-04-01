extends Control

signal move_left_pressed
signal move_left_released
signal move_right_pressed
signal move_right_released
signal jump_pressed
signal attack_pressed

func _ready():
	await get_tree().process_frame
	var btn_size = Vector2(200, 200)
	var margin = 20
	var bottom_margin = -150
	var screen = get_viewport_rect().size

	$Left.custom_minimum_size = btn_size
	$Left.position = Vector2(margin, screen.y - btn_size.y - bottom_margin)
	$Left.expand_icon = true
	$Left.focus_mode = Control.FOCUS_NONE

	$Right.custom_minimum_size = btn_size
	$Right.position = Vector2(margin + btn_size.x + 70, screen.y - btn_size.y - bottom_margin)
	$Right.expand_icon = true
	$Right.focus_mode = Control.FOCUS_NONE

	$Attack.custom_minimum_size = btn_size
	$Attack.position = Vector2(screen.x - btn_size.x - margin, screen.y - btn_size.y - bottom_margin)
	$Attack.expand_icon = true
	$Attack.focus_mode = Control.FOCUS_NONE

	$Jump.custom_minimum_size = btn_size
	$Jump.position = Vector2(screen.x - btn_size.x * 2 - margin - 70, screen.y - btn_size.y - bottom_margin)
	$Jump.expand_icon = true
	$Jump.focus_mode = Control.FOCUS_NONE

	$Left.button_down.connect(func(): move_left_pressed.emit())
	$Left.button_up.connect(func(): move_left_released.emit())
	$Right.button_down.connect(func(): move_right_pressed.emit())
	$Right.button_up.connect(func(): move_right_released.emit())
	$Jump.button_down.connect(func(): jump_pressed.emit())
	$Attack.button_down.connect(func(): attack_pressed.emit())
