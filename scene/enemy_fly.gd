extends CharacterBody2D

const FLY_SPEED = 100.0
const SINE_AMPLITUDE = 60.0
const SINE_FREQUENCY = 2.0
const STOMP_THRESHOLD = 50.0

@export var knockback_strength := 400.0  # Configurable per enemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _start_pos: Vector2
var _time := 0.0
var _dir := 1.0

func _ready() -> void:
	_start_pos = global_position

func _physics_process(delta: float) -> void:
	_time += delta
	var speed = FLY_SPEED * GameManager.get_enemy_speed_mult()
	position.x += _dir * speed * delta
	# Sine wave vertical movement
	position.y = _start_pos.y + sin(_time * SINE_FREQUENCY) * SINE_AMPLITUDE

	# Reverse direction at patrol range
	if abs(position.x - _start_pos.x) >= 200.0:
		_dir *= -1.0

	if sprite:
		sprite.flip_h = _dir < 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var y_delta = position.y - body.position.y
		# Check if player is trying to stomp from above
		if y_delta > STOMP_THRESHOLD and body.velocity.y > 0:
			# Flying enemy can't be stomped - bounce player off with feedback
			body.velocity.y = -400
			if sprite:
				# White flash + shake effect
				var orig_mod = sprite.modulate
				sprite.modulate = Color(3, 3, 3, 1)
				var tween = create_tween()
				tween.tween_property(sprite, "modulate", Color(1.2, 0.3, 0.3, 1), 0.1)  # Red tint
				tween.tween_property(sprite, "modulate", orig_mod, 0.15)
		else:
			# Normal damage to player
			if body.take_hit():
				GameManager.decrease_health()
				# Knockback away from enemy
				var x_delta = body.position.x - position.x
				body.jump_side(knockback_strength if x_delta > 0 else -knockback_strength)
