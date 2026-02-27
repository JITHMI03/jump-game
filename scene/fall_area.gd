extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_fall_hit()
		GameManager.decrease_health()
		body.global_position = body.get_meta("spawn_position", body.get_meta("initial_position", body.global_position))
		body.velocity = Vector2.ZERO
		body.reset_jump_state()
		var cam = body.get_node_or_null("Camera2D")
		if cam:
			cam.reset_smoothing()
