extends CharacterBody2D

@export var speed: float = 100.0
@export var jump_velocity : float = -345.0
@export var rise_gravity_mult: float = 1.1
@export var fall_gravity_mult: float = 2.0
@export var acceleration: float = 250
@export var friction: float = 600
@export var is_active: bool = true
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var light = get_parent().get_node("Light")
@onready var glow: PointLight2D = $PointLight2D
@onready var smash_ray: RayCast2D = $SmashRay
@onready var smash_ray_left: RayCast2D = $SmashRay2
@onready var smash_ray_right: RayCast2D = $SmashRay3
@export var min_smash_speed: float = 20.0
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
	var warmup := CPUParticles2D.new()
	warmup.emitting = true
	warmup.one_shot = true
	warmup.amount = 1
	warmup.lifetime = 0.05
	warmup.modulate.a = 0.0
	add_child(warmup)
	warmup.finished.connect(warmup.queue_free)
	
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
		glow.visible = true
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
		var direction := Input.get_axis("ui_left", "ui_right")
		var target_speed := direction * speed
		var change_rate = acceleration if direction != 0.0 else friction
		
		velocity.x = move_toward(velocity.x, target_speed, change_rate * delta)
		if direction < 0.0:
			anim.play("walk_left")
		elif direction > 0.0:
			anim.play("walk_right")
		else:
			anim.play("active")
	
	else:
		glow.visible = false
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		anim.play("inactive")
	
	if velocity.y >= min_smash_speed:
		var broke_any: bool = false
		for ray in [smash_ray, smash_ray_left, smash_ray_right]:
			if not ray:
				continue
			ray.force_raycast_update()
			if ray.is_colliding():
				var collider : Object = ray.get_collider()
				if collider is TileMapLayer and collider.is_in_group("breakable"):
					var hit_pos: Vector2 = ray.get_collision_point() + Vector2(0, 2)
					var cell_coords: Vector2i = collider.local_to_map(collider.to_local(hit_pos))
					if collider.get_cell_source_id(cell_coords) != -1:
						var tile_world_pos: Vector2 = collider.to_global(collider.map_to_local(cell_coords))
						collider.erase_cell(cell_coords)
						spawn_break_particles(tile_world_pos)
						broke_any = true
		if broke_any:
			velocity.y *= 0.5
			if camera and camera.has_method("add_shake"):
				camera.add_shake(5.0)
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
		0.0, 1.6, 0.08
	)
	tween.tween_method(
		func(value: float):
			crt_material.set_shader_parameter("swap_pulse", value),
		1.6, 0.0, 0.25
	)

func landing_shake():
	var tween = create_tween()
	tween.tween_property(camera, "offset", Vector2(0, 2), 0.04)
	tween.tween_property(camera, "offset", Vector2(0, -2), 0.04)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.08)
	
func spawn_break_particles(world_pos: Vector2) -> void:
	var particles := CPUParticles2D.new()
	particles.global_position = world_pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = 12
	particles.lifetime = 0.45
	var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	particles.texture = ImageTexture.create_from_image(img)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(6.0, 6.0)
	particles.direction = Vector2(0, -1)
	particles.spread = 160.0
	particles.initial_velocity_min = 45.0
	particles.initial_velocity_max = 115.0
	particles.gravity = Vector2(0, 480.0)
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 2.5
	var grad := Gradient.new()
	grad.set_color(0, Color("#D47426"))
	grad.set_color(1, Color("#272D3400"))
	grad.add_point(0.5, Color("#55606B"))
	particles.color_ramp = grad
	get_parent().add_child(particles)
	particles.finished.connect(particles.queue_free)
	
