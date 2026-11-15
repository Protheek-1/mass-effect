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
@onready var label: Label = $Label
@onready var sprite: ColorRect = $ColorRect
var is_active: bool = false
var entered_body: CharacterBody2D
var manager: Node

func _ready() -> void:
	add_to_group("doors")
	manager = get_tree().get_first_node_in_group("door_manager")
	if manager:
		manager.register_door(self)
	match allowed_character:
		CharacterType.HEAVY:
			label.text = "H"
		CharacterType.LIGHT:
			label.text = "L"
		CharacterType.BOTH:
			label.text = "B"
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color.BLACK)


func accepts_character(body: Node2D) -> bool:
	match allowed_character:
		CharacterType.HEAVY:
			return body.name == "Heavy"
		CharacterType.LIGHT:
			return body.name == "Light"
		CharacterType.BOTH:
			return body.name == "Heavy" or body.name == "Light"
	return false
	
func set_active(active: bool) -> void:
	is_active = active
	sprite.color = Color(0.495, 0.694, 0.496, 1.0) if active else Color.WHITE
