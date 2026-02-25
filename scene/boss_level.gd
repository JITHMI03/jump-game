extends Node

func _ready() -> void:
	var boss = get_node_or_null("scene object/boss")
	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)
		boss.health_changed.connect(_on_boss_health_changed)
	# Initialize bar to full
	_on_boss_health_changed(3)

func _on_boss_health_changed(hp: int) -> void:
	var bar = get_node_or_null("ui/boss_health_ui/bar_bg/bar_fill")
	if bar:
		var pct = float(hp) / 3.0
		bar.anchor_right = pct

func _on_boss_defeated() -> void:
	await get_tree().create_timer(1.0).timeout
	var lc = get_node_or_null("ui/level_complete")
	if lc:
		lc.show_complete(null)
	else:
		Transition.fade_to_scene("res://scene/main_menu.tscn")
