extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
func _on_controls_button_pressed() -> void:
	$ControlsPanel.show()
func _on_back_button_pressed() -> void:
	$ControlsPanel.hide()
