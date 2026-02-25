extends Area2D

@export var target_level: PackedScene
@export var level_complete_node: Node

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not target_level:
			return
		if level_complete_node:
			level_complete_node.show_complete(target_level)
		else:
			get_tree().change_scene_to_packed(target_level)
