extends CanvasLayer



func _on_restart_game_button_button_down() -> void:
	Signals.scene_changed.emit(Constants.LEVEL_1_SCENE_PATH)
	queue_free()


func _on_main_menu_button_button_down() -> void:
	Signals.scene_changed.emit(Constants.MAIN_MENU_SCENE_PATH)
	queue_free()
