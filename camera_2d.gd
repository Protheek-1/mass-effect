extends Camera2D

@export var player: CharacterBody2D 

const ROOM_WIDTH: float = 512.0
const ROOM_HEIGHT: float = 352.0

var start_offset: Vector2

func _ready() -> void:
	start_offset = global_position
	position_smoothing_enabled = true
	position_smoothing_speed = 10.0 

func _process(_delta: float) -> void:
	if not player:
		return

	var rel_x: float = player.global_position.x - start_offset.x + (ROOM_WIDTH / 2.0)
	var rel_y: float = player.global_position.y - start_offset.y + (ROOM_HEIGHT / 2.0)

	var grid_x: float = floor(rel_x / ROOM_WIDTH)
	var grid_y: float = floor(rel_y / ROOM_HEIGHT)

	global_position = start_offset + Vector2(
		grid_x * ROOM_WIDTH,
		grid_y * ROOM_HEIGHT
	)
