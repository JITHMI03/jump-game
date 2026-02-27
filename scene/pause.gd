extends Node

@onready var pause_panel: Panel = $PausePanel

var sfx_pause: AudioStream = preload("res://sfx_pause.wav")
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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			_play_sfx(sfx_pause)
			pause_panel.show()
		else:
			pause_panel.hide()

func _on_resume_pressed() -> void:
	_play_sfx(sfx_button)
	pause_panel.hide()
	get_tree().paused = false

func _on_menu_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	Transition.fade_to_scene("res://scene/main_menu.tscn")

func _on_restart_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	Transition.fade_to_scene(get_tree().current_scene.scene_file_path)

func _on_checkpoint_pressed() -> void:
	_play_sfx(sfx_button)
	get_tree().paused = false
	pause_panel.hide()
	# Find player and respawn at checkpoint
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var spawn_pos = player.get_meta("spawn_position", player.get_meta("initial_position", player.global_position))
		player.global_position = spawn_pos
		player.velocity = Vector2.ZERO
		if player.has_method("reset_jump_state"):
			player.reset_jump_state()
