extends Node

var _next_level: PackedScene

@onready var panel: Panel = $LevelCompletePanel
@onready var score_label: Label = $LevelCompletePanel/VBoxContainer/score_label

func show_complete(next_level: PackedScene) -> void:
	_next_level = next_level
	var pts = GameManager.points
	var best = GameManager.best_score
	# Update best score on level complete too
	if pts > best:
		GameManager.best_score = pts
		GameManager._save_best_score()
		best = pts
	score_label.text = "Score: " + str(pts) + ("  |  Best: " + str(best) if best > 0 else "")
	panel.show()
	get_tree().paused = true

func _on_next_pressed() -> void:
	get_tree().paused = false
	Transition.fade_to_packed(_next_level)

func _on_menu_pressed() -> void:
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/main_menu.tscn")
