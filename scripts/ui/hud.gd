class_name HUD
extends CanvasLayer

@export var score_label: Label
@export var life_label: Label
@export var time_progress_bar: TextureProgressBar
@export var start_level_timer_label: Label


func set_start_level_time(value: int) -> void:
	if value <= 0:
		start_level_timer_label.hide()
	start_level_timer_label.text = "%d" % value


func set_score(score: int) -> void:
	# TODO: Сделать в ретро-стиле - с ведущими нулями.
	score_label.text = "%d" % score


func set_lives(lives: int) -> void:
	life_label.text = "%d" % lives


func set_level_time(time: int) -> void:
	time_progress_bar.value = time


func setup(lives: int, level_time: int, start_level_time: int) -> void:
	set_lives(lives)
	
	time_progress_bar.max_value = level_time
	time_progress_bar.value = time_progress_bar.max_value

	set_start_level_time(start_level_time)
