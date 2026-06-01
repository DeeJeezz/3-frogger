extends Node

const _SAVE_PATH: String = "user://save_data.json"


func save_session(session: Dictionary) -> void:
	var file = FileAccess.open(_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(session))
	file.close()


func load_last_session() -> Dictionary:
	if not FileAccess.file_exists(_SAVE_PATH):
		print_debug("Save file not found")
		return {}

	var file = FileAccess.open(_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open save file")
		return {}

	var content = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(content) == OK:
		return json.data
	push_error("Unable to parse save file")
	save_session({})
	return {}
