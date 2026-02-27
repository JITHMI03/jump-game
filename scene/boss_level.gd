extends Node

var sfx_boss_defeat: AudioStream = preload("res://sfx_boss_defeat.wav")

func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var p = AudioStreamPlayer.new()
	p.stream = stream
	p.pitch_scale = randf_range(0.95, 1.05)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _ready() -> void:
	var boss = get_node_or_null("scene object/boss")
	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)
		boss.health_changed.connect(_on_boss_health_changed)
		# Initialize bar to full only if boss exists
		_on_boss_health_changed(boss.hp if boss.has_method("get") else 3)
	else:
		push_warning("Boss node not found at 'scene object/boss'")

func _on_boss_health_changed(hp: int) -> void:
	var bar = get_node_or_null("ui/boss_health_ui/bar_bg/bar_fill")
	if bar:
		var pct = max(0.0, float(hp)) / 3.0
		# Use size instead of anchor for consistency with boss.gd
		bar.custom_minimum_size.x = pct * bar.get_parent().size.x
		bar.size.x = pct * bar.get_parent().size.x

func _on_boss_defeated() -> void:
	_play_sfx(sfx_boss_defeat)
	await get_tree().create_timer(1.0).timeout
	var lc = get_node_or_null("ui/level_complete")
	if lc:
		lc.show_complete(null)
	else:
		Transition.fade_to_scene("res://scene/main_menu.tscn")
