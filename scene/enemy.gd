extends RigidBody2D

const PATROL_SPEED = 120.0
const PATROL_RANGE = 150.0
const HIT_THRESHOLD = 185.0
const KNOCKBACK_VELOCITY = 500.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var sfx_stomp: AudioStream

var _start_x: float
var _patrol_dir := 1.0

func _ready() -> void:
	_start_x = position.x

func _physics_process(_delta: float) -> void:
	linear_velocity.x = PATROL_SPEED * _patrol_dir
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
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var y_delta = position.y - body.position.y
		var x_delta = body.position.x - position.x
		if y_delta > HIT_THRESHOLD:
			_play_oneshot(sfx_stomp)
			queue_free()
			body.jump()
		else:
			if body.take_hit():
				GameManager.decrease_health()
				if x_delta > 0:
					body.jump_side(KNOCKBACK_VELOCITY)
				else:
					body.jump_side(-KNOCKBACK_VELOCITY)
