extends Area2D
class_name Door
enum DoorType { ENTRY, EXIT }
enum CharacterType {HEAVY, LIGHT, BOTH}
@export var door_type: DoorType = DoorType.ENTRY
@export var linked_door: Door
@export var allowed_character: CharacterType = CharacterType.BOTH
@export var is_goal_door: bool = false
@onready var arrival_point: Marker2D = $ArrivalPoint
@export var partner_door: Door
var is_active: bool = false
var entered_body: CharacterBody2D
var manager: Node

func _ready() -> void:
	add_to_group("doors")
	manager = get_tree().get_first_node_in_group("door_manager")

	if manager:
		manager.register_door(self)

func accepts_character(body: Node2D) -> bool:
	match allowed_character:
		CharacterType.HEAVY:
			return body.name == "Heavy"
		CharacterType.LIGHT:
			return body.name == "Light"
		CharacterType.BOTH:
			return body.name == "Heavy" or body.name == "Light"
	return false
