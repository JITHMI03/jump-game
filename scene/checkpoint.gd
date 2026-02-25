extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite2D

var _activated := false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _activated:
		_activated = true
		body.set_meta("spawn_position", global_position)
		if sprite:
			sprite.animation = "active"
		_pulse()

func _pulse() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
