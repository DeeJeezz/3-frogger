extends Pickable

@onready var sfx_player: AudioStreamPlayer2D = $SFX


func apply_effect(..._args) -> void:
	if visible:
		visible = false
		sfx_player.play()
		sfx_player.finished.connect(queue_free)
		Signals.add_life.emit()
