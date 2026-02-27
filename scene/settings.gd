extends Node

const SAVE_PATH = "user://settings.json"

@onready var master_slider: HSlider = $SettingsPanel/VBoxContainer/master_row/master_slider
@onready var sfx_slider: HSlider = $SettingsPanel/VBoxContainer/sfx_row/sfx_slider
@onready var touch_toggle: CheckButton = $SettingsPanel/VBoxContainer/touch_row/touch_toggle
@onready var difficulty_btn: OptionButton = $SettingsPanel/VBoxContainer/difficulty_row/difficulty_btn
@onready var panel: Panel = $SettingsPanel

const DIFFICULTY_NAMES = ["Easy", "Normal", "Hard"]

func _ready() -> void:
	panel.hide()
	_setup_difficulty_button()
	_load_settings()

func _setup_difficulty_button() -> void:
	if not difficulty_btn:
		return
	difficulty_btn.clear()
	for name in DIFFICULTY_NAMES:
		difficulty_btn.add_item(name)
	difficulty_btn.selected = int(GameManager.difficulty)

func show_settings() -> void:
	panel.show()

func hide_settings() -> void:
	panel.hide()

func _on_master_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
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

func _on_difficulty_btn_item_selected(index: int) -> void:
	GameManager.set_difficulty(index as GameManager.Difficulty)
	_save_settings()

func _save_settings() -> void:
	var data = {
		"master": master_slider.value,
		"sfx": sfx_slider.value,
		"touch": touch_toggle.button_pressed,
		"difficulty": int(GameManager.difficulty)
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func _load_settings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_apply_default_settings()
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		_apply_default_settings()
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data:
		_apply_default_settings()
		return
	if data.has("master"):
		master_slider.value = float(data["master"])
		var master_bus_idx = AudioServer.get_bus_index("Master")
		if master_bus_idx >= 0:
			AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(float(data["master"])))
	if data.has("sfx"):
		var sfx_val = float(data["sfx"])
		sfx_slider.value = sfx_val
		var bus_idx = AudioServer.get_bus_index("SFX")
		if bus_idx >= 0:
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_val))
	if data.has("touch"):
		var touch_enabled = bool(data["touch"])
		touch_toggle.button_pressed = touch_enabled
		GameManager.set_meta("touch_enabled", touch_enabled)
		_apply_touch_visibility(touch_enabled)
	if data.has("difficulty") and difficulty_btn:
		var diff = int(data["difficulty"])
		difficulty_btn.selected = diff
		GameManager.difficulty = diff as GameManager.Difficulty

func _apply_default_settings() -> void:
	master_slider.value = 1.0
	sfx_slider.value = 1.0
	touch_toggle.button_pressed = true
	GameManager.set_meta("touch_enabled", true)
	# Apply default audio settings to AudioServer
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx >= 0:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(1.0))
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(1.0))
