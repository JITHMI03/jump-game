extends Area2D

@export var target_level: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not target_level:
			return
		var lc = get_tree().current_scene.get_node_or_null("ui/level_complete")
		if lc:
			lc.show_complete(target_level)
		else:
			get_tree().change_scene_to_packed(target_level)
