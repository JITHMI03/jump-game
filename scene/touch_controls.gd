extends Control

var _was_paused := false

func _process(_delta: float) -> void:
	var is_paused = get_tree().paused
	if is_paused != _was_paused:
		_was_paused = is_paused
		visible = not is_paused
