extends Node

@onready var pause_panel: Panel = $PausePanel

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			pause_panel.show()
		else:
			pause_panel.hide()

func _on_resume_pressed() -> void:
	pause_panel.hide()
	get_tree().paused = false

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
