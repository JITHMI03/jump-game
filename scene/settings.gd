extends Node

const SAVE_PATH = "user://settings.json"

@onready var master_slider: HSlider = $SettingsPanel/VBoxContainer/master_row/master_slider
@onready var sfx_slider: HSlider = $SettingsPanel/VBoxContainer/sfx_row/sfx_slider
@onready var touch_toggle: CheckButton = $SettingsPanel/VBoxContainer/touch_row/touch_toggle
@onready var panel: Panel = $SettingsPanel

func _ready() -> void:
	panel.hide()
	_load_settings()

func show_settings() -> void:
	panel.show()

func hide_settings() -> void:
	panel.hide()

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	_save_settings()

func _on_sfx_slider_value_changed(value: float) -> void:
	# If there's no SFX bus, this silently affects master
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	_save_settings()

func _on_touch_toggle_toggled(pressed: bool) -> void:
	# Show/hide touch controls by setting a meta that touch_controls.gd can check
	GameManager.set_meta("touch_enabled", pressed)
	_apply_touch_visibility(pressed)
	_save_settings()

func _apply_touch_visibility(enabled: bool) -> void:
	var root = get_tree().current_scene
	if not root:
		return
	var tc = root.get_node_or_null("ui/touch_controls")
	if tc:
		tc.visible = enabled

func _on_close_pressed() -> void:
	hide_settings()

func _save_settings() -> void:
	var data = {
		"master": master_slider.value,
		"sfx": sfx_slider.value,
		"touch": touch_toggle.button_pressed
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func _load_settings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		master_slider.value = 1.0
		sfx_slider.value = 1.0
		touch_toggle.button_pressed = true
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data:
		return
	if data.has("master"):
		master_slider.value = float(data["master"])
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(float(data["master"])))
	if data.has("sfx"):
		sfx_slider.value = float(data["sfx"])
	if data.has("touch"):
		touch_toggle.button_pressed = bool(data["touch"])
