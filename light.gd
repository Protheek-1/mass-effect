extends CharacterBody2D

@export var speed: float = 90.0
@export var jump_velocity : float = -340.0
@export var rise_gravity_mult = 0.8
@export var fall_gravity_mult = 0.6
@export var acceleration: float = 450
@export var friction: float = 100
@export var is_active: bool = false

var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("swap_charectar"):
		if is_active == true:
			is_active = false
		else:
			is_active = true
	if not is_active:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		if not is_on_floor():
			velocity.y += base_gravity * delta * fall_gravity_mult
		move_and_slide()
		return
		
	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += base_gravity * delta * rise_gravity_mult
		else:
			velocity.y += base_gravity * delta * fall_gravity_mult
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
