extends Node

var score: int = 0
var record_score: int = 0


func serialize() -> Dictionary:
	
	if record_score < score:
		record_score = score
	
	return {
		"record_score": record_score,
	}


func deserialize(session: Dictionary) -> void:
	record_score = session.get("record_score", record_score)


func save_session() -> void:
	SaveManager.save_session(serialize())


func load_session() -> void:
	var last_session: Dictionary = SaveManager.load_last_session()
	deserialize(last_session)
