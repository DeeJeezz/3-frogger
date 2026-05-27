class_name Frogger
extends Node2D

@export var ground_layer: TileMapLayer

var is_on_water: bool = false

var _previous_direction: Vector2 = Vector2.DOWN
var _can_move: bool = true
var _floating: bool = false
var _death_in_progress: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_box: Area2D = $HurtBox


func _ready() -> void:
	animated_sprite.animation_finished.connect(_play_idle_animation)


func _physics_process(_delta: float) -> void:
	_handle_input()
	if is_on_water and not _floating:
		if not _death_in_progress:
			_death()


func _check_boundaries(next_position: Vector2) -> bool:
	if next_position.x >= Constants.SCREEN_SIZE.x or next_position.x < 0:
		return false
	if next_position.y < 0 or next_position.y >= Constants.SCREEN_SIZE.y:
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
	_is_on_water()


func _is_on_water() -> void:
	var local_position: Vector2 = ground_layer.to_local(global_position)
	var tile_position: Vector2i = ground_layer.local_to_map(local_position)
	var tile: TileData = ground_layer.get_cell_tile_data(tile_position)

	if tile == null:
		set_deferred("is_on_water", false)
	else:
		set_deferred("is_on_water", tile.get_custom_data(Constants.WATER_TILEMAP_LAYER_NAME) == true)


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


func _death() -> void:
	_death_in_progress = true
	_can_move = false
	hurt_box.set_deferred("monitoring", false)
	hurt_box.set_deferred("monitorable", false)
	animated_sprite.animation_finished.disconnect(_play_idle_animation)
	animated_sprite.play("death")
	Signals.game_over.emit()
	animated_sprite.animation_finished.connect(queue_free)


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
	if area.collision_layer == Constants.DEATH_COLLISION_LAYER:
		_death()
		return
	# If player moved on the floating object.
	elif area.collision_layer == Constants.FLOATING_COLLISION_LAYER:
		_floating = true
		_snap_to_local_grid(area)
		return


func _on_hurt_box_area_exited(area: Area2D) -> void:
	if area.collision_layer == Constants.FLOATING_COLLISION_LAYER:

		# Check if player moved to another floating area.
		var next_areas: Array[Area2D] = hurt_box.get_overlapping_areas()
		for next_area in next_areas:
			if area.collision_layer == Constants.FLOATING_COLLISION_LAYER:
				_floating = true
				return

		_snap_to_global_grid()
		_floating = false
		return
