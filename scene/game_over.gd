extends Node

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

func _on_restart_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)

func _on_menu_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/main_menu.tscn")
