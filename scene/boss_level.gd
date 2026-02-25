extends Node

func _ready() -> void:
	var boss = get_node_or_null("scene object/boss")
	if boss:
		boss.boss_defeated.connect(_on_boss_defeated)

func _on_boss_defeated() -> void:
	# Small delay then show level complete
	await get_tree().create_timer(1.0).timeout
	var lc = get_node_or_null("ui/level_complete")
	if lc:
		lc.show_complete(null)  # null target = goes to main menu
	else:
		Transition.fade_to_scene("res://scene/main_menu.tscn")
