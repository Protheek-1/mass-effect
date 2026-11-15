extends Node
var heavy_ready := false
var light_ready := false
var heavy_body: CharacterBody2D
var light_body: CharacterBody2D
var heavy_goal: Door
var light_goal: Door
var transitioning := false
func _enter_tree() -> void:
	add_to_group("door_manager")
	
func register_door(door: Door) -> void:
	door.body_entered.connect(_on_body_entered.bind(door))
	door.body_exited.connect(_on_body_exited.bind(door))
	
	if door.is_goal_door and door.door_type == Door.DoorType.ENTRY:
		heavy_goal = door
	elif door.allowed_character == Door.CharacterType.LIGHT:
		light_goal = door
		
func _on_body_entered(body: Node2D, door: Door) -> void:
	if transitioning:
		return
	if door.door_type != Door.DoorType.ENTRY:
		return
	if not door.accepts_character(body):
		return
	if door.door_type == Door.DoorType.EXIT:
		return
	if door.is_goal_door:
		if body.name == "Heavy":
			heavy_ready = true
			heavy_body = body
		elif body.name == "Light":
			light_ready = true
			light_body = body
		check_goal()
	else:
		door.is_active = true
		door.entered_body = body
		if door.partner_door == null:
			return
		if not door.partner_door.is_active:
			return
		transitioning = true
		teleport_character(
			door.entered_body, 
			door.linked_door
		)
		teleport_character(
		door.partner_door.entered_body,
		door.partner_door.linked_door
	)
func _on_body_exited(body: Node2D, door: Door):
	if transitioning or not door.is_goal_door:
		return
	if body == heavy_body:
		heavy_ready = false
		heavy_body = null
	if body == light_body:
		light_ready = false
		light_body = null
func check_goal() -> void:
	if not heavy_ready or not light_ready:
		return
	if heavy_goal == null or light_goal == null:
		push_warning("forgor door")
		return
	transitioning = true
	teleport_character(heavy_body, heavy_goal.linked_door)
	teleport_character(light_body, light_goal.linked_door)
func teleport_character(body: CharacterBody2D, destination: Door) -> void:
	if body == null or destination == null:
		return
	body.global_position = destination.arrival_point.global_position
	body.velocity = Vector2.ZERO
