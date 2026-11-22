extends Node2D

@onready var timer_label: Label = $Timer
@onready var camera: Camera2D = $Camera2D
var elapsed_time:float = 0.0
var timer_running: bool = false
var timer_finished: bool = false
var timer_lerp: float = 0.0

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
		var start_pos := top_left + Vector2(22.0, 16.0)
		var center_pos := top_left + Vector2((view_size.x - timer_label.size.x * timer_label.scale.x) * 0.5, 20.0)
		timer_label.global_position = start_pos.lerp(center_pos, timer_lerp)
func finish_timer() -> void:
	if timer_finished:
		return
	timer_finished = true
	timer_running = false
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "timer_lerp", 1.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(timer_label, "scale", Vector2(1.4, 1.4), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
