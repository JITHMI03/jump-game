extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -900.0
const DECELERATION = 20.0
const INVINCIBLE_DURATION = 1.5
const COYOTE_TIME = 0.15
const JUMP_BUFFER_TIME = 0.12
const FLICKER_INTERVAL = 0.2

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var camera: Camera2D = $Camera2D

var jump_count = 0
var invincible_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false

func _ready() -> void:
	set_meta("spawn_position", global_position)

func is_invincible() -> bool:
	return invincible_timer > 0.0

# Called by enemies — respects invincibility frames
func take_hit() -> bool:
	if is_invincible():
		return false
	invincible_timer = INVINCIBLE_DURATION
	_screen_shake(6.0, 0.2)
	return true

# Called by fall_area — always triggers (falling is not blockable)
func take_fall_hit() -> void:
	invincible_timer = INVINCIBLE_DURATION
	_screen_shake(6.0, 0.2)

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
	# --- Invincibility flicker ---
	if invincible_timer > 0.0:
		invincible_timer -= delta
		sprite_2d.modulate.a = 0.3 if fmod(invincible_timer, FLICKER_INTERVAL) > FLICKER_INTERVAL * 0.5 else 1.0
		if invincible_timer <= 0.0:
			invincible_timer = 0.0
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

	# --- Jump execution (buffer + coyote combined) ---
	var can_jump = (on_floor or coyote_timer > 0.0) and jump_count < 1
	var double_jump = not on_floor and coyote_timer <= 0.0 and jump_count == 1
	if jump_buffer_timer > 0.0 and (can_jump or double_jump):
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# --- Gravity ---
	if not on_floor:
		velocity += get_gravity() * delta

	# --- Movement ---
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)

	move_and_slide()

	# --- Animations ---
	if on_floor:
		if abs(velocity.x) > 1:
			sprite_2d.animation = "running"
		else:
			sprite_2d.animation = "default"
	else:
		if jump_count >= 2:
			sprite_2d.animation = "double"
		else:
			sprite_2d.animation = "jumping"

	sprite_2d.flip_h = velocity.x < 0
	was_on_floor = on_floor
