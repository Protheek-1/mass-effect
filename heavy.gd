extends CharacterBody2D

@export var speed: float = 100.0
@export var jump_velocity : float = -340.0
@export var rise_gravity_mult: float = 1.1
@export var fall_gravity_mult: float = 2.0
@export var acceleration: float = 250
@export var friction: float = 600
@export var is_active: bool = true
@onready var light = get_parent().get_node("Light")
@onready var crt_material: ShaderMaterial = get_parent().get_node("Filter").material
var base_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var carrying_light: bool = false
var light_offset := Vector2.ZERO
var carried_shape: CollisionShape2D
@onready var camera = get_parent().get_node("Camera2D")
var was_on_floor: bool = false

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
		play_swap_pulse()
	if carrying_light and light.is_active:
		stop_carrying()
	if not carrying_light and is_active:
		if light.is_standing_on_heavy():
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
	
	if is_on_floor() and not was_on_floor:
		landing_shake()
	was_on_floor = is_on_floor()
	
	if carrying_light:
		light.global_position = global_position + light_offset
		light.velocity = velocity
	
func start_carrying() -> void:
	var source_shape: CollisionShape2D = light.get_node("CollisionShape2D")
	light_offset = light.global_position - global_position
	carried_shape.shape = source_shape.shape
	carried_shape.transform = (
		global_transform.affine_inverse()
		* source_shape.global_transform
	)
	carrying_light = true
	light.carried_by_heavy = true
	source_shape.set_deferred("disabled", true)
	carried_shape.set_deferred("disbaled", false)
	
func stop_carrying() -> void:
	var source_shape: CollisionShape2D = light.get_node(
        "CollisionShape2D"
	)
	
	light.global_position = global_position + light_offset
	light.velocity = velocity
	carrying_light = false
	light.carried_by_heavy = false
	
	carried_shape.set_deferred("disbaled", true)
	source_shape.set_deferred("disabled", false)
	
func apply_launch(launch_power: float) -> void:
	velocity.y = launch_power


func play_swap_pulse():
	var tween = create_tween()
	tween.tween_method(
		func(value: float):
			crt_material.set_shader_parameter("swap_pulse", value),
		0.0, 1.0, 0.08
	)
	tween.tween_method(
		func(value: float):
			crt_material.set_shader_parameter("swap_pulse", value),
		1.0, 0.0, 0.25
	)

func landing_shake():
	var tween = create_tween()
	tween.tween_property(camera, "offset", Vector2(0, 2), 0.04)
	tween.tween_property(camera, "offset", Vector2(0, -2), 0.04)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.08)
