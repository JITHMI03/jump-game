extends RigidBody2D

const PATROL_SPEED = 120.0
const PATROL_RANGE = 150.0
const HIT_THRESHOLD = 185.0

@export var knockback_strength := 500.0  # Configurable per enemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var sfx_stomp: AudioStream

var _start_x: float
var _patrol_dir := 1.0

func _ready() -> void:
	_start_x = position.x

func _physics_process(_delta: float) -> void:
	var speed = PATROL_SPEED * GameManager.get_enemy_speed_mult()
	linear_velocity.x = speed * _patrol_dir
	if position.x >= _start_x + PATROL_RANGE:
		_patrol_dir = -1.0
	elif position.x <= _start_x - PATROL_RANGE:
		_patrol_dir = 1.0
	sprite.flip_h = _patrol_dir < 0

func _play_oneshot(stream: AudioStream) -> void:
	if not stream:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = randf_range(0.95, 1.05)
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var y_delta = position.y - body.position.y
		var x_delta = body.position.x - position.x
		if y_delta > HIT_THRESHOLD:
			_play_oneshot(sfx_stomp)
			GameManager.trigger_stomp_multiplier()
			body.jump()
			_die_with_effect()
		else:
			if body.take_hit():
				GameManager.decrease_health()
				if x_delta > 0:
					body.jump_side(knockback_strength)
				else:
					body.jump_side(-knockback_strength)

func _die_with_effect() -> void:
	# Disable collision immediately
	set_deferred("freeze", true)
	$Area2D.set_deferred("monitoring", false)

	# White flash + squash animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color(3, 3, 3, 1), 0.05)  # Flash white
	tween.tween_property(self, "scale", Vector2(1.4, 0.3), 0.1)  # Squash
	tween.set_parallel(false)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.1)  # Fade out
	tween.tween_callback(queue_free)
