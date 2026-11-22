extends Area2D
class_name PressurePlate

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var bodies_on_plate: int = 0
var collision_rest_y: float = 0.0

func _ready() -> void:
	add_to_group("pressure_plates")
	if anim:
		anim.play("unpressed")
	if collision:
		collision_rest_y = collision.position.y
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var warmup := CPUParticles2D.new()
	warmup.emitting = true
	warmup.one_shot = true
	warmup.amount = 1
	warmup.lifetime = 0.05
	warmup.modulate.a = 0.0
	add_child(warmup)
	warmup.finished.connect(warmup.queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Heavy" and body.name != "Light":
		return
	bodies_on_plate += 1
	if bodies_on_plate >= 1:
		_set_pressed(true)
func _on_body_exited(body: Node2D) -> void:
	if body.name != "Heavy" and body.name != "Light":
		return
	bodies_on_plate = max(0, bodies_on_plate - 1)
	if bodies_on_plate == 0:
		_set_pressed(false)
	
func _set_pressed(pressed: bool) -> void:
	if anim:
		anim.play("pressed" if pressed else "unpressed")
	if collision:
		collision.set_deferred("position:y", collision_rest_y + (2.0 if pressed else 0.0))
	var any_pressed: bool = false
	for plate in get_tree().get_nodes_in_group("pressure_plates"):
		if plate.bodies_on_plate > 0:
			any_pressed = true
			break
	for layer in get_tree().get_nodes_in_group("breakable"):
		if layer is TileMapLayer:
			if layer.collision_enabled == any_pressed:
				for cell in layer.get_used_cells():
					var world_pos: Vector2 = layer.to_global(layer.map_to_local(cell))
					_spawn_phase_particles(world_pos, any_pressed)
			layer.collision_enabled = not any_pressed
			layer.modulate.a = 0.20 if any_pressed else 1.0
		
func _spawn_phase_particles(world_pos: Vector2, phasing_out: bool) -> void:
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
