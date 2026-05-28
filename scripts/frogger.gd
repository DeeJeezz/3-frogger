class_name Frogger
extends Node2D

signal moved
signal died

@export var move_sfx: AudioStream
@export var water_death_sfx: AudioStream
@export var road_death_sfx: AudioStream
@export var finish_sfx: AudioStream

var is_on_water: bool = false
var can_move: bool = false

var _finished: bool = false
var _previous_direction: Vector2 = Vector2.DOWN
var _can_move: bool = true
var _floating: bool = false
var _death_in_progress: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_box: Area2D = $HurtBox
#region SFX
@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer

#endregion


func _ready() -> void:
	animated_sprite.animation_finished.connect(_play_idle_animation)


func _physics_process(_delta: float) -> void:
	if _finished:
		return

	if not can_move:
		return

	_handle_input()
	if is_on_water and not _floating:
		death()
	if position.x < 0 or position.x >= Constants.SCREEN_SIZE.x:
		death()


func finish() -> void:
	set_deferred("_finished", true)
	hurt_box.set_deferred("monitoring", false)
	animated_sprite.animation_finished.disconnect(_play_idle_animation)
	animated_sprite.play("pre_finish")
	animated_sprite.animation_finished.connect(animated_sprite.play.bind("finish"))
	sfx_player.stream = finish_sfx
	sfx_player.play()


func death() -> void:
	if _death_in_progress:
		return
	_death_in_progress = true
	_can_move = false
	hurt_box.set_deferred("monitoring", false)
	hurt_box.set_deferred("monitorable", false)
	animated_sprite.animation_finished.disconnect(_play_idle_animation)
	animated_sprite.play("death")
	if is_on_water:
		sfx_player.stream = water_death_sfx
	else:
		sfx_player.stream = road_death_sfx
	sfx_player.play()
	animated_sprite.animation_finished.connect(queue_free)


func _check_boundaries(next_position: Vector2) -> bool:
	if next_position.x >= Constants.SCREEN_SIZE.x or next_position.x < 0:
		return false
	if next_position.y < Constants.STEP_SIZE * 2 or next_position.y >= Constants.SCREEN_SIZE.y - Constants.STEP_SIZE * 2:
		return false

	return true


func _move(direction: Vector2) -> void:
	if not _can_move:
		return

	_previous_direction = direction

	var next_position: Vector2 = position + direction * Constants.STEP_SIZE
	if not _check_boundaries(next_position):
		return
	position = next_position
	animated_sprite.stop()
	if abs(direction.x) > 0:
		if direction.x > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
		animated_sprite.play("walk_side")
	elif direction.y > 0:
		animated_sprite.play("walk_down")
	elif direction.y < 0:
		animated_sprite.play("walk_up")
	moved.emit()
	sfx_player.stream = move_sfx
	sfx_player.play()


func _handle_input() -> void:
	if Input.is_action_just_pressed("move_left"):
		_move(Vector2.LEFT)
	elif Input.is_action_just_pressed("move_right"):
		_move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("move_up"):
		_move(Vector2.UP)
	elif Input.is_action_just_pressed("move_down"):
		_move(Vector2.DOWN)


func _play_idle_animation() -> void:
	if abs(_previous_direction.x) > 0:
		animated_sprite.play("idle_side")
	elif _previous_direction.y > 0:
		animated_sprite.play("idle_down")
	elif _previous_direction.y < 0:
		animated_sprite.play("idle_up")


func _exit_tree() -> void:
	died.emit()


## Snaps object to local grid.
func _snap_to_local_grid(object: Node2D) -> void:
	var local: Vector2 = object.to_local(global_position)
	var closest_grid_point_x: float = snapped(local.x, Constants.STEP_SIZE)
	var global_grid: Vector2 = object.to_global(Vector2(closest_grid_point_x, 0))
	global_position.x = global_grid.x


## Snaps object to global grid.
func _snap_to_global_grid() -> void:
	var closest_grid_point_x: float = snapped(position.x, Constants.STEP_SIZE)
	global_position.x = closest_grid_point_x


func _on_hurt_box_area_entered(area: Area2D) -> void:
	# If player moved on the floating object.
	if area is Log:
		_floating = true
		_snap_to_local_grid(area)
		return
	# If player moved on the other MovingObstacle.
	elif area is MovingObstacle:
		death()
		return


func _on_hurt_box_area_exited(area: Area2D) -> void:
	if area is Log:
		if hurt_box.monitoring:
			# Check if player moved to another floating area.
			var next_areas: Array[Area2D] = hurt_box.get_overlapping_areas()
			for next_area in next_areas:
				if area is Log:
					_floating = true
					return

		_floating = false
		_snap_to_global_grid()
		return
