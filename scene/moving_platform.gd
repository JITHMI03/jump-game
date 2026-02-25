extends AnimatableBody2D

@export var move_distance := 200.0
@export var move_speed := 80.0
@export var move_vertical := false

var _start_pos: Vector2
var _dir := 1.0

func _ready() -> void:
	_start_pos = position

func _physics_process(delta: float) -> void:
	var travel = _dir * move_speed * delta
	if move_vertical:
		position.y += travel
		var dist = position.y - _start_pos.y
		if dist >= move_distance:
			_dir = -1.0
		elif dist <= 0.0:
			_dir = 1.0
	else:
		position.x += travel
		var dist = position.x - _start_pos.x
		if dist >= move_distance:
			_dir = -1.0
		elif dist <= 0.0:
			_dir = 1.0
