extends Node

var sfx_game_over: AudioStream = preload("res://sfx_game_over.wav")
var sfx_button: AudioStream = preload("res://sfx_button.wav")
var _played_sfx := false

func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var p = AudioStreamPlayer.new()
	p.stream = stream
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _ready() -> void:
	# Play game over sound when this node becomes visible
	var panel = get_node_or_null("GameOverPanel")
	if panel and panel.visible and not _played_sfx:
		_play_sfx(sfx_game_over)
		_played_sfx = true

func show_game_over() -> void:
	if not _played_sfx:
		_play_sfx(sfx_game_over)
		_played_sfx = true

func _on_restart_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)

func _on_menu_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/main_menu.tscn")
