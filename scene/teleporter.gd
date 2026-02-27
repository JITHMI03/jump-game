extends Area2D

## Paired teleporter. Link to another teleporter via the target export.

@export var target: NodePath  # Path to the destination teleporter
@export var sfx_teleport: AudioStream

@onready var visual: ColorRect = $visual

var _cooldown := false
const COOLDOWN_TIME = 0.5

func _ready() -> void:
	# Portal swirl animation
	var tween = create_tween().set_loops()
	tween.tween_property(visual, "rotation", TAU, 2.0)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _cooldown:
		return

	var dest = get_node_or_null(target)
	if not dest:
		push_warning("Teleporter: No valid target set!")
		return

	# Set cooldown on both teleporters
	_cooldown = true
	if dest.has_method("set_cooldown"):
		dest.set_cooldown(true)

	# Teleport effect
	_play_sfx()
	_flash_effect(body)

	# Move player
	body.global_position = dest.global_position
	body.velocity = Vector2.ZERO

	# Reset cooldown after delay
	get_tree().create_timer(COOLDOWN_TIME).timeout.connect(_reset_cooldown)
	get_tree().create_timer(COOLDOWN_TIME).timeout.connect(dest.set_cooldown.bind(false))

func set_cooldown(val: bool) -> void:
	_cooldown = val

func _reset_cooldown() -> void:
	_cooldown = false

func _flash_effect(body: Node2D) -> void:
	var orig = body.modulate
	body.modulate = Color(2, 2, 3, 1)
	var tween = create_tween()
	tween.tween_property(body, "modulate", orig, 0.2)

func _play_sfx() -> void:
	if not sfx_teleport:
		return
	var p = AudioStreamPlayer.new()
	p.stream = sfx_teleport
	p.pitch_scale = randf_range(0.9, 1.1)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
