extends Node

@export_group("Button Colors")
@export var level1_base: Color = Color("22c55e")
var sfx_button: AudioStream = preload("res://sfx_button.wav")

func _ready() -> void:
	var lbl = get_node_or_null("bestscore_label")
	if lbl:
		var best = GameManager.best_score
		if best > 0:
			lbl.text = "TOP SCORE - " + str(best).pad_zeros(3)
		else:
			lbl.text = "TOP SCORE - 000"

	# Apply new blocky Mario-style pixel styles
	_style_button("level1", Color("f8d820"), Color.BLACK)
	_style_button("level2", Color("f8d820"), Color.BLACK)
	_style_button("level3", Color("f8d820"), Color.BLACK)
	_style_button("settings_btn", Color("a8a8a8"), Color.BLACK)

	# Add blocky shift animations
	for btn_name in ["level1", "level2", "level3", "settings_btn"]:
		var btn = get_node_or_null(btn_name)
		if btn:
			# Only connect signals for hard movement
			btn.button_down.connect(_on_btn_down.bind(btn))
			btn.button_up.connect(_on_btn_up.bind(btn))
			btn.mouse_exited.connect(_on_btn_up.bind(btn)) # reset on exit if pressed

func _style_button(btn_name: String, base_color: Color, border_color: Color) -> void:
	var btn = get_node_or_null(btn_name)
	if not btn: return
	
	# Normal Style - completely blocky, thick borders
	var sb_normal = StyleBoxFlat.new()
	sb_normal.bg_color = base_color
	sb_normal.border_color = border_color
	sb_normal.border_width_left = 6
	sb_normal.border_width_right = 6
	sb_normal.border_width_top = 6
	sb_normal.border_width_bottom = 6
	sb_normal.corner_radius_top_left = 0
	sb_normal.corner_radius_top_right = 0
	sb_normal.corner_radius_bottom_right = 0
	sb_normal.corner_radius_bottom_left = 0
	
	# Small drop shadow effect in the actual rect if possible, but thick borders do the trick
	sb_normal.shadow_color = Color(0, 0, 0, 0.5)
	sb_normal.shadow_size = 4
	sb_normal.shadow_offset = Vector2(6, 6)
	
	btn.add_theme_stylebox_override("normal", sb_normal)
	
	# Hover Style - slightly lighter color, same border
	var sb_hover = sb_normal.duplicate()
	sb_hover.bg_color = base_color.lightened(0.2)
	btn.add_theme_stylebox_override("hover", sb_hover)
	
	# Pressed Style - no shadow, simulated push down
	var sb_pressed = sb_normal.duplicate()
	sb_pressed.bg_color = base_color.darkened(0.2)
	sb_pressed.shadow_size = 0
	sb_pressed.shadow_offset = Vector2(0, 0)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	
	# Focus Style (invisible)
	var sb_empty = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("focus", sb_empty)
	
	# Font Colors overrides (crisp black)
	btn.add_theme_color_override("font_color", Color.BLACK)
	btn.add_theme_color_override("font_hover_color", Color.BLACK)
	btn.add_theme_color_override("font_pressed_color", Color.BLACK)

func _on_btn_down(btn: Button) -> void:
	# Shift the button down to simulate pressing a block
	if not btn.has_meta("original_pos"):
		btn.set_meta("original_pos", btn.position)
	var pos = btn.get_meta("original_pos")
	btn.position = pos + Vector2(6, 6)

func _on_btn_up(btn: Button) -> void:
	if btn.has_meta("original_pos"):
		btn.position = btn.get_meta("original_pos")

func _play_sfx() -> void:
	if not sfx_button:
		return
	var p = AudioStreamPlayer.new()
	p.stream = sfx_button
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _on_level_1_pressed() -> void:
	_play_sfx()
	Transition.fade_to_scene("res://scene/level1.tscn")

func _on_level_2_pressed() -> void:
	_play_sfx()
	Transition.fade_to_scene("res://scene/level2.tscn")

func _on_level_3_pressed() -> void:
	_play_sfx()
	Transition.fade_to_scene("res://scene/level3.tscn")

func _on_settings_pressed() -> void:
	_play_sfx()
	var s = get_node_or_null("settings")
	if s:
		s.show_settings()

func _update_level_buttons() -> void:
	# Add checkmark to completed levels
	var level_data = [
		["level1", "Level 1"],
		["level2", "Level 2"],
		["level3", "Level 3"]
	]
	for data in level_data:
		var btn = get_node_or_null(data[0])
		if btn:
			var level_name = data[0]
			var display_name = data[1]
			if GameManager.is_level_complete(level_name):
				btn.text = display_name + " ✓"
			else:
				btn.text = display_name
