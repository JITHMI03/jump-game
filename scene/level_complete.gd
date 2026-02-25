extends Node

var _next_level: PackedScene

@onready var panel: Panel = $LevelCompletePanel
@onready var score_label: Label = $LevelCompletePanel/VBoxContainer/score_label

func show_complete(next_level: PackedScene) -> void:
	_next_level = next_level
	score_label.text = "Score: " + str(GameManager.points)
	panel.show()
	get_tree().paused = true

func _on_next_pressed() -> void:
	get_tree().paused = false
	Transition.fade_to_packed(_next_level)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/main_menu.tscn")
