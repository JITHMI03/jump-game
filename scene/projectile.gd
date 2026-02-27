extends Area2D

const SPEED = 250.0
const LIFETIME = 4.0

var direction := Vector2.RIGHT
var _timer := LIFETIME

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	_timer -= delta
	if _timer <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.take_hit():
			GameManager.decrease_health()
			var x_delta = body.position.x - position.x
			body.jump_side(350.0 if x_delta > 0 else -350.0)
		queue_free()
	elif body.is_in_group("ground"):
		queue_free()
