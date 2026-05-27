extends CanvasLayer


func _on_start_game_button_button_down() -> void:
	Signals.scene_changed.emit(Constants.LEVEL_1_SCENE_PATH)


func _on_leaders_button_button_down() -> void:
	pass # Replace with function body.


func _on_quit_game_button_button_down() -> void:
	get_tree().quit()
