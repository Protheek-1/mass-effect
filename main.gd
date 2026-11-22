extends Node2D

@onready var timer_label: Label = $Timer
@onready var camera: Camera2D = $Camera2D
var elapsed_time:float = 0.0
var timer_running: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_level"):
		get_tree().reload_current_scene()
		
func _unhandled_input(event: InputEvent) -> void:
	if not timer_running:
		if (
			event.is_action_pressed("ui_left")
			or event.is_action_pressed("ui_right")
			or event.is_action_pressed("ui_accept")
			or event.is_action_pressed("ui_up")
			or event.is_action_pressed("jump")
		):
			timer_running = true
func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		var minutes := int(elapsed_time / 60.0)
		var seconds := int(elapsed_time) % 60
		var centiseconds := int((elapsed_time - floor(elapsed_time)) * 100.0)
		timer_label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]
	if timer_label and camera:
		var view_size := get_viewport_rect().size / camera.zoom
		var top_left := camera.get_screen_center_position() - (view_size * 0.5)
		timer_label.global_position = top_left + Vector2(22.0, 16.0)
