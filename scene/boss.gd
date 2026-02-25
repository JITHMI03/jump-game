extends CharacterBody2D

enum Phase { PATROL, CHARGE, JUMP_SLAM }

const PATROL_SPEED = 80.0
const CHARGE_SPEED = 350.0
const PATROL_RANGE = 250.0
const JUMP_VELOCITY = -1000.0
const STOMP_GRAVITY_MULT = 6.0
const STOMP_HIT_THRESHOLD = 60.0
const MAX_HEALTH = 3
const PHASE_INTERVAL = 4.0
const CHARGE_DURATION = 0.7
const SLAM_RISE_WAIT = 0.5

signal health_changed(hp: int)
signal boss_defeated

@onready var sprite: ColorRect = $sprite
@onready var health_bar_fill: ColorRect = $health_bar/fill

@export var sfx_stomp: AudioStream
@export var sfx_charge: AudioStream
@export var sfx_hurt: AudioStream

var hp := MAX_HEALTH
var _phase: Phase = Phase.PATROL
var _phase_timer := PHASE_INTERVAL
var _start_x: float
var _patrol_dir := 1.0
var _charge_dir := 1.0
var _charge_timer := 0.0
var _slam_rising := false
var _slam_wait := 0.0
var _player_ref: Node2D = null

func _ready() -> void:
	_start_x = global_position.x
	_update_health_bar()

func _physics_process(delta: float) -> void:
	_player_ref = _find_player()

	# Gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta * (STOMP_GRAVITY_MULT if _phase == Phase.JUMP_SLAM and velocity.y > 0 else 1.0)

	match _phase:
		Phase.PATROL:
			_do_patrol(delta)
		Phase.CHARGE:
			_do_charge(delta)
		Phase.JUMP_SLAM:
			_do_slam(delta)

	move_and_slide()

	# Flip sprite
	if velocity.x != 0:
		sprite.position.x = -40 if velocity.x > 0 else 0

func _do_patrol(delta: float) -> void:
	velocity.x = PATROL_SPEED * _patrol_dir
	if abs(global_position.x - _start_x) >= PATROL_RANGE:
		_patrol_dir *= -1.0

	_phase_timer -= delta
	if _phase_timer <= 0.0:
		_next_phase()

func _do_charge(delta: float) -> void:
	_charge_timer -= delta
	velocity.x = _charge_dir * CHARGE_SPEED
	if _charge_timer <= 0.0 or is_on_wall():
		_phase = Phase.PATROL
		_phase_timer = PHASE_INTERVAL

func _do_slam(delta: float) -> void:
	if _slam_rising:
		_slam_wait -= delta
		if _slam_wait <= 0.0:
			_slam_rising = false
			# Slam down toward player x
			if _player_ref:
				_charge_dir = sign(_player_ref.global_position.x - global_position.x)
				velocity.x = _charge_dir * CHARGE_SPEED * 0.5
			velocity.y = JUMP_VELOCITY * -0.3
	if is_on_floor() and not _slam_rising:
		# Landed — shake and return to patrol
		_screen_shake()
		_phase = Phase.PATROL
		_phase_timer = PHASE_INTERVAL

func _next_phase() -> void:
	var r = randi() % 2
	if r == 0:
		_phase = Phase.CHARGE
		_charge_timer = CHARGE_DURATION
		if _player_ref:
			_charge_dir = sign(_player_ref.global_position.x - global_position.x)
		else:
			_charge_dir = _patrol_dir
		_play_sfx(sfx_charge)
	else:
		_phase = Phase.JUMP_SLAM
		velocity.y = JUMP_VELOCITY
		_slam_rising = true
		_slam_wait = SLAM_RISE_WAIT

func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null

func take_stomp() -> void:
	hp -= 1
	health_changed.emit(hp)
	_update_health_bar()
	_play_sfx(sfx_hurt)
	if hp <= 0:
		boss_defeated.emit()
		_die()
	else:
		# Flash red briefly
		var orig = sprite.color
		sprite.color = Color.RED
		var tween = create_tween()
		tween.tween_property(sprite, "color", orig, 0.3)
		# Brief invincibility / knockback phase
		_phase = Phase.PATROL
		_phase_timer = 2.0

func _die() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 0.1), 0.3)
	tween.tween_callback(queue_free)

func _update_health_bar() -> void:
	if health_bar_fill:
		health_bar_fill.size.x = (float(hp) / MAX_HEALTH) * 160.0

func _screen_shake() -> void:
	var cam = _player_ref.get_node_or_null("Camera2D") if _player_ref else null
	if not cam:
		return
	var tween = create_tween()
	for i in 6:
		var offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		tween.tween_property(cam, "offset", offset, 0.04)
	tween.tween_property(cam, "offset", Vector2.ZERO, 0.04)

func _play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	var p = AudioStreamPlayer.new()
	p.stream = stream
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var y_delta = global_position.y - body.global_position.y
	if y_delta > STOMP_HIT_THRESHOLD and velocity.y <= 0:
		# Player stomps boss from above
		take_stomp()
		body.jump()
	else:
		if body.take_hit():
			GameManager.decrease_health()
			var x_delta = body.global_position.x - global_position.x
			body.jump_side(500.0 if x_delta > 0 else -500.0)
