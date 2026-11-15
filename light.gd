extends CharacterBody2D

@export var speed: float = 90.0
@export var jump_velocity : float = -340.0
@export var rise_gravity_mult: float = 0.8
@export var fall_gravity_mult: float = 0.5
@export var acceleration: float = 450
@export var friction: float = 300
@export var is_active: bool = false
@onready var floor_ray: RayCast2D = $FloorRay
@onready var floor_ray_left: RayCast2D = $FloorRayLeft
@onready var floor_ray_right: RayCast2D = $FloorRayRight
@onready var head_ray: RayCast2D = $HeadRay
@onready var heavy = get_parent().get_node("Heavy")
var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var carried_by_heavy: bool = false

func _physics_process(delta: float) -> void:
	if carried_by_heavy:
		return
		
	if not is_on_floor():
		var gravity_mult: float = (
			rise_gravity_mult if velocity.y < 0.0
			else fall_gravity_mult
		)
		velocity.y += base_gravity * gravity_mult * delta
		
	head_ray.force_raycast_update()
	floor_ray.force_raycast_update()
	
	var heavy_on_top: bool = (
		head_ray.is_colliding()
		and head_ray.get_collider() == heavy
	)
	var standing_on_heavy: bool = is_standing_on_heavy()
	
	if is_active:
		if (
			Input.is_action_just_pressed("jump")
			and (is_on_floor() or standing_on_heavy)
			and not heavy_on_top
		):
			velocity.y = jump_velocity
		
		var direction := Input.get_axis("ui_left", "ui_right")
		var target_speed := direction * speed
		var change_rate := (
			acceleration if direction != 0.0 else friction
		)
		
		velocity.x = move_toward(velocity.x, target_speed, change_rate * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	move_and_slide()
		
func apply_launch(launch_power: float) -> void:
	if carried_by_heavy:
		heavy.apply_launch(launch_power)
	else:
		velocity.y = launch_power
func is_standing_on_heavy() -> bool:
	for ray in [floor_ray, floor_ray_left, floor_ray_right]:
		ray.force_raycast_update()
		if ray.is_colliding() and ray.get_collider() == heavy:
			return true
	return false
