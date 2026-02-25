extends Area2D

@onready var gamemanager: Node = %gamemanager

func _on_body_entered(body: Node2D) -> void:
	if not gamemanager:
		return
	if body.is_in_group("player"):
		body.take_fall_hit()
		gamemanager.decrease_health()
