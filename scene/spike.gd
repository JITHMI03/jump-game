extends Area2D

## Spike trap that extends and retracts. Instant kill, ignores invincibility.

@export var extend_time := 1.5  # Time spikes are out
@export var retract_time := 2.0  # Time spikes are in
@export var warning_time := 0.5  # Flash before extending

@onready var spike_visual: ColorRect = $spike_visual
@onready var collision: CollisionShape2D = $CollisionShape2D

var _extended := false
var _timer := 0.0
var _warning := false

func _ready() -> void:
	_retract()
	_timer = retract_time

func _process(delta: float) -> void:
	_timer -= delta

	if _extended:
		if _timer <= 0.0:
			_retract()
			_timer = retract_time
	else:
		# Warning flash before extending
		if _timer <= warning_time and not _warning:
			_warning = true
			_start_warning()
		if _timer <= 0.0:
			_extend()
			_timer = extend_time

func _extend() -> void:
	_extended = true
	_warning = false
	collision.disabled = false
	spike_visual.modulate = Color(1, 0.2, 0.2, 1)  # Red when extended
	# Animate extension
	var tween = create_tween()
	tween.tween_property(spike_visual, "scale:y", 1.0, 0.1)

func _retract() -> void:
	_extended = false
	collision.disabled = true
	spike_visual.modulate = Color(0.5, 0.5, 0.5, 1)  # Gray when retracted
	# Animate retraction
	var tween = create_tween()
	tween.tween_property(spike_visual, "scale:y", 0.2, 0.15)

func _start_warning() -> void:
	# Flash to warn player
	var tween = create_tween().set_loops(3)
	tween.tween_property(spike_visual, "modulate", Color(1, 0.5, 0, 1), 0.08)
	tween.tween_property(spike_visual, "modulate", Color(0.5, 0.5, 0.5, 1), 0.08)

func _on_body_entered(body: Node2D) -> void:
	if not _extended:
		return
	if body.is_in_group("player"):
		# Instant kill - bypass invincibility
		GameManager.lives = 0
		GameManager.health_changed.emit(0)
		GameManager.game_over.emit(GameManager.points)
