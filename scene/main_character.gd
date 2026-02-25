extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -900.0
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

var jump_count = 0

func jump():
	velocity.y = JUMP_VELOCITY

func jump_side(x):
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _physics_process(delta: float) -> void:
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
