extends CanvasLayer

@onready var quit_button: Button = $VBoxContainer/QuitGameButton


func _ready() -> void:
	if OS.get_name() == "Web":
		quit_button.hide()


func _on_start_game_button_button_down() -> void:
	Signals.scene_changed.emit(Constants.LEVEL_1_SCENE_PATH)


func _on_quit_game_button_button_down() -> void:
	get_tree().quit()
