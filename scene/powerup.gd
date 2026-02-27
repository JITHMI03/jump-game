extends Area2D

enum Type { STAR, SHIELD, SPEED, SLOW, GHOST }

@export var type: Type = Type.STAR

const STAR_DURATION = 5.0
const SHIELD_DURATION = 8.0
const SPEED_DURATION = 5.0
const SPEED_MULTIPLIER = 1.6
const SLOW_DURATION = 3.0
const SLOW_SCALE = 0.5
const GHOST_DURATION = 4.0

@export var sfx_powerup: AudioStream

func _ready() -> void:
	_set_color()
	# Bob animation
	var visual = get_node_or_null("icon")
	if visual:
		var start_y = visual.position.y
		var tween = create_tween().set_loops()
		tween.tween_property(visual, "position:y", start_y - 8, 0.5)
		tween.tween_property(visual, "position:y", start_y, 0.5)

func _set_color() -> void:
	var rect = get_node_or_null("icon")
	if not rect:
		return
	match type:
		Type.STAR:
			rect.color = Color(1, 0.9, 0, 1)
		Type.SHIELD:
			rect.color = Color(0.2, 0.6, 1, 1)
		Type.SPEED:
			rect.color = Color(0, 1, 0.4, 1)
		Type.SLOW:
			rect.color = Color(0.6, 0.3, 0.8, 1)  # Purple
		Type.GHOST:
			rect.color = Color(0.9, 0.9, 1, 0.7)  # Translucent white

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_play_sfx()
	match type:
		Type.STAR:
			_apply_star(body)
		Type.SHIELD:
			_apply_shield(body)
		Type.SPEED:
			_apply_speed(body)
		Type.SLOW:
			_apply_slow()
		Type.GHOST:
			_apply_ghost(body)
	queue_free()

func _apply_star(body: CharacterBody2D) -> void:
	# Brief invincibility + score multiplier
	body.invincible_timer = STAR_DURATION
	GameManager.trigger_stomp_multiplier()
	GameManager.trigger_stomp_multiplier()  # Push to x3

func _apply_shield(body: CharacterBody2D) -> void:
	# One free hit: set invincibility for shield duration
	body.invincible_timer = SHIELD_DURATION

func _apply_speed(body: CharacterBody2D) -> void:
	_boost_speed(body)

func _boost_speed(body: CharacterBody2D) -> void:
	# We set a meta flag that main_character.gd speed is boosted
	body.set_meta("speed_boost", SPEED_MULTIPLIER)
	body.set_meta("speed_boost_timer", SPEED_DURATION)

func _apply_slow() -> void:
	# Slow down time for everything except player
	Engine.time_scale = SLOW_SCALE
	# Restore normal speed after duration
	get_tree().create_timer(SLOW_DURATION * SLOW_SCALE).timeout.connect(_restore_time_scale)
	# Visual effect - slight desaturation would require shader, so we'll skip for now

func _restore_time_scale() -> void:
	Engine.time_scale = 1.0

func _apply_ghost(body: CharacterBody2D) -> void:
	# Make player pass through enemies
	body.set_collision_mask_value(4, false)  # Disable enemy collision
	body.modulate = Color(1, 1, 1, 0.5)  # Translucent
	body.set_meta("ghost_mode", true)
	# Restore after duration
	get_tree().create_timer(GHOST_DURATION).timeout.connect(_end_ghost.bind(body))

func _end_ghost(body: CharacterBody2D) -> void:
	if not is_instance_valid(body):
		return
	body.set_collision_mask_value(4, true)  # Re-enable enemy collision
	body.modulate = Color(1, 1, 1, 1)
	body.remove_meta("ghost_mode")

func _play_sfx() -> void:
	if not sfx_powerup:
		return
	var p = AudioStreamPlayer.new()
	p.stream = sfx_powerup
	p.pitch_scale = randf_range(0.95, 1.05)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
