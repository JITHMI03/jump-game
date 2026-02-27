extends Area2D

const BOUNCE_VELOCITY = -1600.0

@export var sfx_bounce: AudioStream

var _initial_scale: Vector2

func _ready() -> void:
	_initial_scale = scale

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.velocity.y = BOUNCE_VELOCITY
		body.jump_count = 0
		_play_bounce_sfx()
		_squash_anim()

func _play_bounce_sfx() -> void:
	if not sfx_bounce:
		return
	var player = AudioStreamPlayer.new()
	player.stream = sfx_bounce
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _squash_anim() -> void:
	var tween = create_tween()
	var base = _initial_scale
	tween.tween_property(self, "scale", base * Vector2(1.4, 0.5), 0.08)
	tween.tween_property(self, "scale", base * Vector2(0.8, 1.3), 0.1)
	tween.tween_property(self, "scale", base, 0.1)
