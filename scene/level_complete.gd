extends Node

var _next_level: PackedScene

@onready var panel: Panel = $LevelCompletePanel
@onready var score_label: Label = $LevelCompletePanel/VBoxContainer/score_label

var sfx_complete: AudioStream = preload("res://sfx_level_complete.wav")
var sfx_button: AudioStream = preload("res://sfx_button.wav")

func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var p = AudioStreamPlayer.new()
	p.stream = stream
	p.pitch_scale = randf_range(0.95, 1.05)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func show_complete(next_level: PackedScene) -> void:
	_next_level = next_level
	var pts = GameManager.points
	# Save best score through GameManager (handles comparison internally)
	GameManager.save_best_score()
	# Mark current level as complete
	var scene_path = get_tree().current_scene.scene_file_path
	if "level1" in scene_path:
		GameManager.mark_level_complete("level1")
	elif "level2" in scene_path:
		GameManager.mark_level_complete("level2")
	elif "level3" in scene_path:
		GameManager.mark_level_complete("level3")
	elif "boss" in scene_path:
		GameManager.mark_level_complete("boss")
	var best = GameManager.best_score
	score_label.text = "Score: " + str(pts) + ("  |  Best: " + str(best) if best > 0 else "")
	# Update next button text
	var next_btn = panel.get_node_or_null("VBoxContainer/next")
	if next_btn:
		next_btn.text = "Next Level" if next_level else "Main Menu"
	_play_sfx(sfx_complete)
	panel.show()
	get_tree().paused = true

func _on_next_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	if _next_level:
		Transition.fade_to_packed(_next_level)
	else:
		Transition.fade_to_scene("res://scene/main_menu.tscn")

func _on_menu_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/main_menu.tscn")
