extends Area2D

@onready var gamemanager: Node = %gamemanager

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		queue_free()
		gamemanager.add_point()
