extends StaticBody2D

## Turret that fires at the player. Can be destroyed by stomping.

const PROJECTILE_SCENE = preload("res://scene/projectile.tscn")
const FIRE_RATE = 2.0  # Seconds between shots
const DETECTION_RANGE = 400.0
const STOMP_THRESHOLD = 30.0

@onready var visual: ColorRect = $visual
@onready var muzzle: Marker2D = $muzzle

@export var sfx_fire: AudioStream
@export var sfx_destroyed: AudioStream

var _fire_timer := FIRE_RATE
var _player_ref: Node2D = null

func _physics_process(delta: float) -> void:
	_player_ref = _find_player()
	if not _player_ref:
		return

	var dist = global_position.distance_to(_player_ref.global_position)
	if dist > DETECTION_RANGE:
		return

	# Aim at player
	var dir_to_player = (_player_ref.global_position - global_position).normalized()
	visual.rotation = dir_to_player.angle()

	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire()
		_fire_timer = FIRE_RATE

func _fire() -> void:
	if not muzzle or not _player_ref:
		return
	var proj = PROJECTILE_SCENE.instantiate()
	proj.global_position = muzzle.global_position
	proj.direction = (_player_ref.global_position - muzzle.global_position).normalized()
	get_tree().root.add_child(proj)
	_play_sfx(sfx_fire)

func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null

func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var p = AudioStreamPlayer.new()
	p.stream = stream
	p.pitch_scale = randf_range(0.95, 1.05)
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var y_delta = global_position.y - body.global_position.y
		if y_delta > STOMP_THRESHOLD and body.velocity.y >= 0:
			# Player stomps turret
			_play_sfx(sfx_destroyed)
			GameManager.trigger_stomp_multiplier()
			body.jump()
			_die()
		else:
			# Player hit by turret body
			if body.take_hit():
				GameManager.decrease_health()
				var x_delta = body.global_position.x - global_position.x
				body.jump_side(400.0 if x_delta > 0 else -400.0)

func _die() -> void:
	var tween = create_tween()
	tween.tween_property(visual, "modulate", Color(3, 3, 3, 1), 0.05)
	tween.tween_property(self, "scale", Vector2(1.3, 0.3), 0.1)
	tween.tween_property(visual, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)
