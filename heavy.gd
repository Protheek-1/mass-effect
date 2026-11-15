extends CharacterBody2D

@export var speed: float = 90.0
@export var jump_velocity : float = -340.0
@export var rise_gravity_mult: float = 1.1
@export var fall_gravity_mult: float = 2.0
@export var acceleration: float = 250
@export var friction: float = 300
@export var is_active: bool = true
@onready var light = get_parent().get_node("Light")
var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var carrying_light: bool = false
var light_offset := Vector2.ZERO
var carried_shape: CollisionShape2D

func _ready() -> void:
	light.is_active = not is_active
	process_physics_priority = -1
	carried_shape = CollisionShape2D.new()
	carried_shape.disabled = true
	add_child(carried_shape)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("swap_charectar"):
		is_active = not is_active
		light.is_active = not is_active
	if carrying_light and light.is_active:
		stop_carrying()
	if not carrying_light and is_active:
		light.floor_ray.force_raycast_update()
		if (
			light.floor_ray.is_colliding()
			and light.floor_ray.get_collider() == self
			and light.velocity.y >= 0.0
		):
			start_carrying()
		
	if not is_on_floor():
		var gravity_mult: float = (
			rise_gravity_mult if velocity.y < 0.0
			else fall_gravity_mult
		)
		velocity.y += base_gravity * gravity_mult * delta
	
	if is_active:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
		var direction := Input.get_axis("ui_left", "ui_right")
		var target_speed := direction * speed
		var change_rate = acceleration if direction != 0.0 else friction
		
		velocity.x = move_toward(velocity.x, target_speed, change_rate * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	move_and_slide()
	
	if carrying_light:
		light.global_position = global_position + light_offset
		light.velocity = velocity
	
func start_carrying() -> void:
	carrying_light = true
	light.carried_by_heavy = true
	light_offset = light.global_position - global_position
	var source_shape: CollisionShape2D = light.get_node("CollisionShape2D")
	carried_shape.shape = source_shape.shape
	carried_shape.transform = (
		global_transform.affine_inverse()
		* source_shape.global_transform
	)
	source_shape.disabled = true
	carried_shape.disabled = false
	
func stop_carrying() -> void:
	carrying_light = false
	light.carried_by_heavy = false
	carried_shape.disabled = true
	var source_shape: CollisionShape2D = light.get_node(
        "CollisionShape2D"
	)
	source_shape.disabled = false
	light.velocity = velocity
	
func apply_launch(launch_power: float) -> void:
	velocity.y = launch_power
	#global_position.y -= 5.0
