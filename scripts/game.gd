extends Node

var _current_scene: Node


func _ready() -> void:
	_load_scene_from_file(Constants.MAIN_MENU_SCENE_PATH)
	Signals.scene_changed.connect(_load_scene_from_file)


func _load_scene_from_file(filename: String) -> void:
	var scene: PackedScene = load(filename)
	var scene_inst: Node = scene.instantiate()
	if _current_scene:
		_current_scene.queue_free()
	add_child(scene_inst)
	_current_scene = scene_inst
