extends AnimatableBody2D

@export var move_distance := 200.0
@export var move_speed := 80.0
@export var move_vertical := false
@export_enum("Positive:1", "Negative:-1") var start_direction: int = 1
@export var use_easing := true

var _start_pos: Vector2

func _ready() -> void:
	_start_pos = position
	var duration = move_distance / move_speed
	var tween = create_tween().set_loops()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	var trans = Tween.TRANS_SINE if use_easing else Tween.TRANS_LINEAR
	
	var target_pos = _start_pos
	if move_vertical:
		target_pos.y += move_distance * start_direction
	else:
		target_pos.x += move_distance * start_direction
		
	tween.tween_property(self, "position", target_pos, duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", _start_pos, duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
