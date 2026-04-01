extends Control

func _ready():
	$VBoxContainer/Play.grab_focus()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://main level/main_level.tscn")

func _on_exit_pressed():
	get_tree().quit()
