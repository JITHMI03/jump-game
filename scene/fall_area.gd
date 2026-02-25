extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_fall_hit()
		GameManager.decrease_health()
		body.global_position = body.get_meta("spawn_position")
		body.velocity = Vector2.ZERO
		body.reset_jump_state()
