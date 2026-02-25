extends Node

func _ready() -> void:
	var lbl = get_node_or_null("bestscore_label")
	if lbl:
		var best = GameManager.best_score
		if best > 0:
			lbl.text = "Best Score: " + str(best)
		else:
			lbl.text = "Best Score: --"

func _on_level_1_pressed() -> void:
	Transition.fade_to_scene("res://scene/level1.tscn")

func _on_level_2_pressed() -> void:
	Transition.fade_to_scene("res://scene/level2.tscn")

func _on_level_3_pressed() -> void:
	Transition.fade_to_scene("res://scene/level3.tscn")

func _on_settings_pressed() -> void:
	var s = get_node_or_null("settings")
	if s:
		s.show_settings()
