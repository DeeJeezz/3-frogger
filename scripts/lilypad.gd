class_name Lilypad
extends MovingObstacle

@export var min_float_time: float = 3.0
@export var max_float_time: float = 6.0

var _hidden: bool = false

@onready var float_timer: Timer = $FloatTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	_start_timer()
	float_timer.timeout.connect(_on_float_timer_timeout)
	animation_player.animation_finished.connect(_on_animation_player_finished)


func set_collision_shape_state(state: bool) -> void:
	collision_shape.disabled = state
	if state:
		_frogger = null


func _on_animation_player_finished(animation_name: StringName) -> void:
	if animation_name == &"show":
		_hidden = false
	elif animation_name == &"hide":
		_hidden = true


func _on_float_timer_timeout() -> void:
	if _hidden:
		animation_player.play(&"show")
	else:
		animation_player.play(&"hide")
	_start_timer()


func _start_timer() -> void:
	float_timer.start(randf_range(min_float_time, max_float_time))
