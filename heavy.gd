extends CharacterBody2D

@export var speed: float = 90.0
@export var jump_velocity : float = -340.0
@export var rise_gravity_mult = 1.1
@export var fall_gravity_mult = 2.0
@export var acceleration: float = 250
@export var friction: float = 300
@export var is_active: bool = true
@onready var head_ray = $RayCast2D
var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var light_is_on_top: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("swap_charectar"):
		if is_active == true:
			is_active = false
		else:
			is_active = true
	if not is_on_floor():
			if velocity.y < 0:
				velocity.y += base_gravity * delta * rise_gravity_mult
			else:
				velocity.y += base_gravity * delta * fall_gravity_mult
		
	if not is_active:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
		if is_on_wall() or is_on_floor():
			for i in range(get_slide_collision_count()):
				var col = get_slide_collision(i)
				if col.get_collider() is CharacterBody2D and col.get_normal().y < 0.7:
					if velocity.y > 0:
						velocity.y = 0
		move_and_slide()
		return
	
	var rider: CharacterBody2D = null
	if head_ray.is_colliding():
		var collider = head_ray.get_collider()
		if collider is CharacterBody2D:
			rider = collider
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or (rider != null and is_character_resting_tight(rider)):
			#global_position = global_position + Vector2(0, 4)
			velocity.y = jump_velocity
			if rider!= null:
				rider.apply_launch(jump_velocity * 0.8)

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
	
func get_character_on_top() -> CharacterBody2D:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, -20))
	query.exclude = [get_rid()]
	
	var result = space_state.intersect_ray(query)
	if result and result.collider is CharacterBody2D:
		return result.collider
	return null
	
func apply_launch(launch_power: float) -> void:
	velocity.y = launch_power
	global_position.y -= 5.0
	move_and_slide()
func is_character_resting_tight(target_rider: CharacterBody2D) -> bool:
	var horizontal_check = abs(target_rider.global_position.x - global_position.x) < 20.0
	var vertical_check = abs(target_rider.global_position.y - global_position.y) < 32.0
	return horizontal_check and vertical_check
