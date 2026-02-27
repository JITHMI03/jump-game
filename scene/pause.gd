extends Node

@onready var pause_panel: Panel = $PausePanel

var sfx_pause: AudioStream = preload("res://sfx_pause.wav")
var sfx_button: AudioStream = preload("res://sfx_button.wav")

func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var p = AudioStreamPlayer.new()
	p.stream = stream
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
