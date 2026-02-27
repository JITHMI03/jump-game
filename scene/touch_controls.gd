extends Control

var _was_paused := false

func _ready() -> void:
	# Check initial touch setting
	_update_visibility()

func _process(_delta: float) -> void:
	var is_paused = get_tree().paused
	if is_paused != _was_paused:
		_was_paused = is_paused
		_update_visibility()

func _update_visibility() -> void:
	# Check if touch is enabled in settings (defaults to true)
	var touch_enabled = GameManager.get_meta("touch_enabled", true)
	# Hide if paused or if touch is disabled in settings
	visible = touch_enabled and not get_tree().paused
