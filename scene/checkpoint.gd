extends Area2D

var sprite: AnimatedSprite2D = null

var _activated := false

func _ready() -> void:
	sprite = get_node_or_null("Sprite2D")

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
