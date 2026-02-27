extends CanvasLayer

const HINT_DURATION = 4.0
const FADE_DURATION = 0.5

var _shown_hints: Dictionary = {}
var _current_tween: Tween = null

@onready var hint_label: Label = $HintPanel/Label
@onready var hint_panel: Panel = $HintPanel

func _ready() -> void:
	hint_panel.modulate.a = 0.0
	_load_shown_hints()

func show_hint(hint_id: String, text: String) -> void:
	# Don't show if hints are disabled in settings
	if GameManager.get_meta("hints_disabled", false):
		return
	# Don't show same hint twice
	if _shown_hints.has(hint_id):
		return
	_shown_hints[hint_id] = true
	_save_shown_hints()

	hint_label.text = text

	# Cancel any existing animation
	if _current_tween:
		_current_tween.kill()

	# Fade in, wait, fade out
	_current_tween = create_tween()
	_current_tween.tween_property(hint_panel, "modulate:a", 1.0, FADE_DURATION)
	_current_tween.tween_interval(HINT_DURATION)
	_current_tween.tween_property(hint_panel, "modulate:a", 0.0, FADE_DURATION)

func _save_shown_hints() -> void:
	var file = FileAccess.open("user://hints.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_shown_hints))
		file.close()

func _load_shown_hints() -> void:
	if not FileAccess.file_exists("user://hints.json"):
		return
	var file = FileAccess.open("user://hints.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data:
			_shown_hints = data

func reset_hints() -> void:
	_shown_hints.clear()
	_save_shown_hints()
