extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -900.0
const INVINCIBLE_DURATION = 1.5

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

var jump_count = 0
var invincible_timer := 0.0

func is_invincible() -> bool:
	return invincible_timer > 0.0

func take_hit():
	if is_invincible():
		return false
	invincible_timer = INVINCIBLE_DURATION
	return true

func jump():
	velocity.y = JUMP_VELOCITY

func jump_side(x):
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _physics_process(delta: float) -> void:
	# Invincibility countdown + flicker effect
	if invincible_timer > 0.0:
		invincible_timer -= delta
		sprite_2d.modulate.a = 0.3 if fmod(invincible_timer, 0.2) > 0.1 else 1.0
		if invincible_timer <= 0.0:
			invincible_timer = 0.0
			sprite_2d.modulate.a = 1.0

	# Add the gravity.
	if is_on_floor():
		jump_count = 0

		#animations
		if velocity.x > 1 || velocity.x < -1:
			sprite_2d.animation = "running"
		else:
			sprite_2d.animation = "default"

	else:
		velocity += get_gravity() * delta
		if jump_count == 2:
			sprite_2d.animation = "double"
		else:
			sprite_2d.animation = "jumping"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count < 2:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 12)

	move_and_slide()

	var isleft = velocity.x < 0
	sprite_2d.flip_h = isleft
