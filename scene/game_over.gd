extends Node

func _on_restart_pressed() -> void:
	get_tree().paused = false
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/main_menu.tscn")
