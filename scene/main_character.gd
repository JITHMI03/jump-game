extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -900.0
const JUMP_CUT_MULTIPLIER = 0.4  # Cut jump to 40% when released early
const GROUND_ACCEL = 2000.0  # Ground acceleration
const AIR_ACCEL = 800.0  # Slower air acceleration
const GROUND_FRICTION = 1500.0  # Ground deceleration
const AIR_FRICTION = 200.0  # Air resistance
const DECELERATION = 20.0  # Legacy fallback
const INVINCIBLE_DURATION = 1.5
const COYOTE_TIME = 0.15
const JUMP_BUFFER_TIME = 0.12
const FLICKER_INTERVAL = 0.2
const DASH_SPEED = 700.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.6

# Wall mechanics
const WALL_SLIDE_GRAVITY = 200.0
const WALL_JUMP_VELOCITY_X = 400.0
const WALL_JUMP_VELOCITY_Y = -800.0
const WALL_JUMP_LOCK_TIME = 0.18

# Camera zoom
const CAMERA_ZOOM_DEFAULT = 1.0
const CAMERA_ZOOM_OUT = 0.9  # Zoom out when airborne at high speed
const CAMERA_ZOOM_SPEED = 3.0

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var _sfx: AudioStreamPlayer = $SFX

var _dash_trail_scene = preload("res://scene/dash_trail.tscn")
var _dash_trail: GPUParticles2D = null

@export var sfx_jump: AudioStream
@export var sfx_double_jump: AudioStream
@export var sfx_land: AudioStream
@export var sfx_hit: AudioStream
@export var sfx_dash: AudioStream
@export var sfx_footstep: AudioStream

var jump_count = 0
var invincible_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var is_dashing := false
var dash_dir := 1.0

var _wall_jump_lock := 0.0
var _on_wall_left := false
var _on_wall_right := false
var _jump_held := false  # For variable jump height
var _footstep_timer := 0.0
const FOOTSTEP_INTERVAL = 0.22

func _ready() -> void:
	set_meta("spawn_position", global_position)
	set_meta("initial_position", global_position)

func is_invincible() -> bool:
	return invincible_timer > 0.0

func _play_sfx(stream: AudioStream) -> void:
	if stream and _sfx:
		_sfx.stream = stream
		_sfx.pitch_scale = randf_range(0.95, 1.05)
		_sfx.play()

# Called by enemies -- respects invincibility frames
func take_hit() -> bool:
	if is_invincible():
		return false
	invincible_timer = INVINCIBLE_DURATION
	_screen_shake(6.0, 0.2)
	_play_sfx(sfx_hit)
	return true

# Called by fall_area -- always triggers (falling is not blockable)
func take_fall_hit() -> void:
	is_dashing = false
	dash_timer = 0.0
	invincible_timer = INVINCIBLE_DURATION
	_screen_shake(6.0, 0.2)
	_play_sfx(sfx_hit)

func reset_jump_state() -> void:
	jump_count = 0
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	was_on_floor = false
	is_dashing = false
	dash_timer = 0.0
	dash_cooldown_timer = 0.0
	_wall_jump_lock = 0.0
	_jump_held = false

func _screen_shake(strength: float, duration: float) -> void:
	var tween = create_tween()
	var steps = int(duration / 0.04)
	for i in steps:
		var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(camera, "offset", offset, 0.04)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.04)

func jump():
	velocity.y = JUMP_VELOCITY

func jump_side(x: float) -> void:
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _physics_process(delta: float) -> void:
	# --- Dash cooldown ---
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	# --- Wall detection ---
	_on_wall_left = is_on_wall() and get_wall_normal().x > 0
	_on_wall_right = is_on_wall() and get_wall_normal().x < 0
	var touching_wall = _on_wall_left or _on_wall_right

	# --- Dash input ---
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		dash_dir = -1.0 if sprite_2d.flip_h else 1.0
		_play_sfx(sfx_dash)
		_start_dash_trail()

	# --- Active dash ---
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_dir * DASH_SPEED
		velocity.y = 0.0
		if dash_timer <= 0.0:
			is_dashing = false
			_stop_dash_trail()
		move_and_slide()
		sprite_2d.modulate.a = 0.6 if fmod(dash_timer, 0.06) > 0.03 else 1.0
		was_on_floor = is_on_floor()
		return

	# --- Wall jump lock ---
	if _wall_jump_lock > 0.0:
		_wall_jump_lock -= delta

	# --- Invincibility flicker ---
	if invincible_timer > 0.0:
		invincible_timer -= delta
		sprite_2d.modulate.a = 0.3 if fmod(invincible_timer, FLICKER_INTERVAL) > FLICKER_INTERVAL * 0.5 else 1.0
		if invincible_timer <= 0.0:
			invincible_timer = 0.0
			sprite_2d.modulate.a = 1.0
	else:
		sprite_2d.modulate.a = 1.0

	# --- Coyote time ---
	var on_floor = is_on_floor()
	if on_floor:
		coyote_timer = COYOTE_TIME
		jump_count = 0
	else:
		if was_on_floor:
			coyote_timer = COYOTE_TIME
		coyote_timer -= delta

	# --- Jump buffer ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# --- Wall slide ---
	var wall_sliding = touching_wall and not on_floor and velocity.y > 0 and _wall_jump_lock <= 0.0
	if wall_sliding:
		velocity.y = move_toward(velocity.y, WALL_SLIDE_GRAVITY, 80.0)

	# --- Wall jump ---
	if jump_buffer_timer > 0.0 and touching_wall and not on_floor and _wall_jump_lock <= 0.0:
		var wall_normal_x = get_wall_normal().x
		velocity.y = WALL_JUMP_VELOCITY_Y
		velocity.x = wall_normal_x * WALL_JUMP_VELOCITY_X
		_wall_jump_lock = WALL_JUMP_LOCK_TIME
		jump_count = 1
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		_play_sfx(sfx_jump)
	else:
		# --- Normal jump (buffer + coyote combined) ---
		var can_jump = (on_floor or coyote_timer > 0.0) and jump_count < 1
		var double_jump = not on_floor and coyote_timer <= 0.0 and jump_count == 1 and not touching_wall
		if jump_buffer_timer > 0.0 and (can_jump or double_jump):
			velocity.y = JUMP_VELOCITY
			_jump_held = true
			if jump_count == 0:
				_play_sfx(sfx_jump)
			else:
				_play_sfx(sfx_double_jump)
			jump_count += 1
			jump_buffer_timer = 0.0
			coyote_timer = 0.0

	# --- Variable jump height (cut jump when button released early) ---
	if _jump_held and Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
		_jump_held = false
	if on_floor:
		_jump_held = false

	# --- Land sound ---
	if on_floor and not was_on_floor:
		_play_sfx(sfx_land)

	# --- Gravity ---
	if not on_floor and not wall_sliding:
		velocity += get_gravity() * delta

	# --- Speed boost power-up ---
	var current_speed = SPEED
	if has_meta("speed_boost"):
		var boost_timer_val = get_meta("speed_boost_timer", 0.0)
		var boost_timer: float = float(boost_timer_val) if boost_timer_val != null else 0.0
		boost_timer -= delta
		if boost_timer <= 0.0:
			remove_meta("speed_boost")
			remove_meta("speed_boost_timer")
		else:
			set_meta("speed_boost_timer", boost_timer)
			var boost_val = get_meta("speed_boost", 1.0)
			var boost_mult: float = float(boost_val) if boost_val != null else 1.0
			current_speed = SPEED * boost_mult

	# --- Movement with momentum ---
	var direction := Input.get_axis("left", "right")
	var accel = GROUND_ACCEL if on_floor else AIR_ACCEL
	var friction = GROUND_FRICTION if on_floor else AIR_FRICTION

	if _wall_jump_lock > 0.0:
		if direction:
			var blend = 1.0 - (_wall_jump_lock / WALL_JUMP_LOCK_TIME)
			velocity.x = move_toward(velocity.x, direction * current_speed, accel * blend * delta)
	else:
		if direction:
			# Accelerate toward target speed
			velocity.x = move_toward(velocity.x, direction * current_speed, accel * delta)
		else:
			# Apply friction to slow down
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

	# --- Footsteps ---
	if on_floor and abs(velocity.x) > 50:
		_footstep_timer -= delta
		if _footstep_timer <= 0.0:
			_play_sfx(sfx_footstep)
			_footstep_timer = FOOTSTEP_INTERVAL
	else:
		_footstep_timer = 0.0  # Reset so first step plays immediately

	# --- Animations ---
	if on_floor:
		if abs(velocity.x) > 1:
			sprite_2d.animation = "running"
		else:
			sprite_2d.animation = "default"
		sprite_2d.flip_h = velocity.x < 0
	elif wall_sliding:
		sprite_2d.animation = "jumping"
		sprite_2d.flip_h = _on_wall_right
	else:
		if jump_count >= 2:
			sprite_2d.animation = "double"
		else:
			sprite_2d.animation = "jumping"
		if velocity.x != 0:
			sprite_2d.flip_h = velocity.x < 0

	# --- Dynamic camera zoom ---
	_update_camera_zoom(delta, on_floor)

	was_on_floor = on_floor

func _update_camera_zoom(delta: float, on_floor: bool) -> void:
	if not camera:
		return
	# Calculate target zoom based on state
	var target_zoom = CAMERA_ZOOM_DEFAULT
	var speed_factor = abs(velocity.x) / SPEED
	var air_factor = 0.0 if on_floor else min(abs(velocity.y) / 600.0, 1.0)

	# Zoom out more when moving fast in air or during dash
	if is_dashing:
		target_zoom = CAMERA_ZOOM_OUT * 0.95
	elif not on_floor and (speed_factor > 0.8 or air_factor > 0.5):
		target_zoom = lerp(CAMERA_ZOOM_DEFAULT, CAMERA_ZOOM_OUT, max(speed_factor, air_factor))

	# Smooth zoom transition
	var current = camera.zoom.x
	var new_zoom = move_toward(current, target_zoom, CAMERA_ZOOM_SPEED * delta)
	camera.zoom = Vector2(new_zoom, new_zoom)

func _start_dash_trail() -> void:
	if _dash_trail:
		_dash_trail.queue_free()
	_dash_trail = _dash_trail_scene.instantiate()
	add_child(_dash_trail)
	_dash_trail.position = Vector2.ZERO
	_dash_trail.emitting = true

func _stop_dash_trail() -> void:
	if _dash_trail:
		_dash_trail.emitting = false
		# Let existing particles fade out then free
		var trail = _dash_trail
		_dash_trail = null
		get_tree().create_timer(0.5).timeout.connect(trail.queue_free)
