extends Area2D

enum Type { STAR, SHIELD, SPEED }

@export var type: Type = Type.STAR

const STAR_DURATION = 5.0
const SHIELD_DURATION = 8.0
const SPEED_DURATION = 5.0
const SPEED_MULTIPLIER = 1.6

@export var sfx_powerup: AudioStream

func _ready() -> void:
	_set_color()
	# Bob animation
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 8, 0.5)
	tween.tween_property(self, "position:y", position.y, 0.5)

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
	# Temporarily boost speed via a timed override
	var orig_speed = body.get("speed_override") if body.get("speed_override") else 0.0
	_boost_speed(body)

func _boost_speed(body: CharacterBody2D) -> void:
	# We set a meta flag that main_character.gd speed is boosted
	body.set_meta("speed_boost", SPEED_MULTIPLIER)
	body.set_meta("speed_boost_timer", SPEED_DURATION)

func _play_sfx() -> void:
	if not sfx_powerup:
		return
	var p = AudioStreamPlayer.new()
	p.stream = sfx_powerup
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
