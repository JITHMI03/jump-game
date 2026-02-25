extends RigidBody2D

@onready var gamemanager: Node = %gamemanager

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var y_delta = position.y - body.position.y
		var x_delta = body.position.x - position.x
		if y_delta > 185:
			print("destroy enemy")
			queue_free()
			body.jump()
		else:
			print("decrease player health")
			gamemanager.decrease_health()
			if x_delta > 0:
				body.jump_side(500)
			else:
				body.jump_side(-500)
