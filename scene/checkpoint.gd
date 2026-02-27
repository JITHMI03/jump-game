extends Area2D

var sprite: AnimatedSprite2D = null

var _activated := false

@export var sfx_checkpoint: AudioStream

func _ready() -> void:
	sprite = get_node_or_null("Sprite2D")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _activated:
		_activated = true
		body.set_meta("spawn_position", global_position)
		if sprite:
			sprite.animation = "active"
		_play_sfx()
		_pulse()

func _play_sfx() -> void:
	if not sfx_checkpoint:
		return
	var p = AudioStreamPlayer.new()
	p.stream = sfx_checkpoint
	p.pitch_scale = randf_range(0.95, 1.05)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _pulse() -> void:
	# Scale bounce
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)

	# Color flash on sprite
	if sprite:
		var orig_mod = sprite.modulate
		var color_tween = create_tween()
		color_tween.tween_property(sprite, "modulate", Color(2, 2, 0.5, 1), 0.1)  # Golden flash
		color_tween.tween_property(sprite, "modulate", Color(1.2, 1.5, 1.2, 1), 0.2)  # Greenish glow
		color_tween.tween_property(sprite, "modulate", orig_mod, 0.3)

	# Floating "Checkpoint!" label
	_spawn_checkpoint_label()

func _spawn_checkpoint_label() -> void:
	var label = Label.new()
	label.text = "Checkpoint!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-50, -60)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1, 0.95, 0.3))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 3)
	add_child(label)

	# Float up and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)
