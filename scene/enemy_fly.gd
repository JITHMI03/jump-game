extends CharacterBody2D

const FLY_SPEED = 100.0
const SINE_AMPLITUDE = 60.0
const SINE_FREQUENCY = 2.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _start_pos: Vector2
var _time := 0.0
var _dir := 1.0

func _ready() -> void:
	_start_pos = global_position

func _physics_process(delta: float) -> void:
	_time += delta
	position.x += _dir * FLY_SPEED * delta
	# Sine wave vertical movement
	position.y = _start_pos.y + sin(_time * SINE_FREQUENCY) * SINE_AMPLITUDE

	# Reverse direction at patrol range
	if abs(position.x - _start_pos.x) >= 200.0:
		_dir *= -1.0

	if sprite:
		sprite.flip_h = _dir < 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.take_hit():
			GameManager.decrease_health()
			# Knockback away from enemy
			var x_delta = body.position.x - position.x
			body.jump_side(400.0 if x_delta > 0 else -400.0)
