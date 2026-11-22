extends Area2D
class_name Door
enum DoorType { ENTRY, EXIT }
enum CharacterType {HEAVY, LIGHT, BOTH}
@export var door_type: DoorType = DoorType.ENTRY
@export var linked_door: Door
@export var allowed_character: CharacterType = CharacterType.BOTH
@export var is_goal_door: bool = false
@onready var arrival_point: Marker2D = $ArrivalPoint
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var partner_door: Door
var is_active: bool = false
var is_closing: bool = false
var entered_body: CharacterBody2D
var manager: Node
var anim_prefix: String = "light"

func _ready() -> void:
	add_to_group("doors")
	z_index = -1
	if allowed_character == CharacterType.HEAVY:
		anim_prefix = "heavy"
	else:
		anim_prefix = "light"
	if anim:
		if door_type == DoorType.EXIT:
			anim.play(anim_prefix + "_pedestal")
		else:
			anim.play(anim_prefix + "_off")
		
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
	
func set_active(active: bool) -> void:
	if is_closing:
		return
	is_active = active
	if anim:
		var state:= "_on" if active else "_off"
		anim.play(anim_prefix + state)
		
func play_close() -> void:
	is_closing = true
	z_index = 1
	if anim:
		anim.play(anim_prefix + "_close")
		
func play_open() -> void:
	is_closing = true
	z_index = 1
	if anim:
		anim.play_backwards(anim_prefix + "_close")
		await anim.animation_finished
	is_closing = false
	z_index = -1 
	if door_type == DoorType.EXIT and anim:
		var tween := create_tween()
		tween.tween_property(anim, "modulate:a", 0.0, 0.12)
		await tween.finished
		anim.play(anim_prefix + "_pedestal")
		var tween_in := create_tween()
		tween_in.tween_property(anim, "modulate:a", 1.0, 0.13)
		await tween_in.finished
	else:
		set_active(false)
