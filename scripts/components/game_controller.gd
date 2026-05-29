extends Node2D

@export_category("Nodes")
## Position to spawn player's [Frogger].
@export var frogger_start_marker: Marker2D
## Link to ground layer of TileMap.
@export var ground_layer: TileMapLayer
## Countdown timer for completing the level.
@export var level_timer: Timer
## Countdown timer before starting the level.
@export var start_level_timer: Timer
@export_category("UI")
## Player [HUD].
@export var hud: HUD
@export_category("Settings")
## How many finish tiles on the level.
@export var finish_tiles: int = 5
## How much time player have to reach finish tile.
@export var level_time: int = 30
## Time to wait before player can control the frogger.
@export var time_to_start: int = 3:
	set(value):
		time_to_start = value
		if hud:
			hud.set_start_level_time(value)

# How many times player can die.
var lives: int = 3:
	set(value):
		lives = value
		hud.set_lives(lives)

# Time counter for level completion. If this time reaches 0, frogger dies.
var _level_time: int = level_time:
	set(value):
		_level_time = value
		if hud:
			hud.set_level_time(value)

var _score: int = 0:
	set(value):
		_score = value
		Session.score = value
		if hud:
			hud.set_score(value)

# Storage for occupied finish tiles positions.
var _occupied_tiles: Array[Vector2i] = []

# Current frogger.
var _frogger: Frogger


func _ready() -> void:
	Session.load_session()
	hud.set_record_score(Session.record_score)
	# Setup timers.
	level_timer.timeout.connect(_on_level_timer_timeout)
	start_level_timer.timeout.connect(_on_start_level_timer_timeout)
	# Setup UI.
	_score = 0
	hud.setup(lives, _level_time, time_to_start)
	# Spawn player's frogger.
	_spawn_frogger(false)
	# Connect signals.
	Signals.add_life.connect(_on_add_life)


## Process "Life" pickup effect.
func _on_add_life() -> void:
	lives += 1
	_score += Constants.SCORE_FOR_PICKUP


## Countdown before player can move frogger.
func _on_start_level_timer_timeout() -> void:
	time_to_start -= 1
	if time_to_start == 0:
		start_level_timer.stop()
		_frogger.can_move = true


## Countdown before player reaches finish tile.
func _on_level_timer_timeout() -> void:
	if not start_level_timer.is_stopped():
		return
	_level_time -= 1
	if _level_time <= 0:
		level_timer.stop()
		_frogger.death()


## Spawns new [Frogger]. [param can_move] describes can player move the [Frogger] right now.
func _spawn_frogger(can_move: bool = false) -> void:
	var frogger_scene: PackedScene = load(Constants.FROGGER_SCENE_PATH)
	var frogger: Frogger = frogger_scene.instantiate()
	frogger.position = frogger_start_marker.position
	get_tree().current_scene.call_deferred("add_child", frogger)
	_frogger = frogger
	_frogger.can_move = can_move
	_frogger.moved.connect(_on_frogger_moved)
	_frogger.died.connect(_on_frogger_died)
	_level_time = level_time
	level_timer.start()


## Signal processor of current [Frogger] death.
func _on_frogger_died() -> void:
	lives -= 1
	if lives > 0:
		_spawn_frogger(true)
	# Defeat game condition.
	else:
		_defeat()
		return


## Checks if [param] tile is "Water" tile. Sets [member Frogger.is_on_water].
func _check_is_on_water(tile: TileData) -> void:
	if tile == null:
		_frogger.set_deferred("is_on_water", false)
	else:
		_frogger.set_deferred("is_on_water", tile.get_custom_data(Constants.WATER_TILEMAP_LAYER_NAME) == true)


## Checks if current [Frogger] position is on finish tile.
func _check_is_on_finish(tile: TileData, tile_position: Vector2i) -> void:
	if tile == null:
		return

	if tile.get_custom_data(Constants.FINISH_TILEMAP_LAYER_NAME):
		if tile_position in _occupied_tiles:
			_frogger.death()
			return
		_frogger.call_deferred("finish")
		_occupied_tiles.append(tile_position)
		_score += Constants.SCORE_FOR_FINISH

		# Win game condition.
		if _occupied_tiles.size() == finish_tiles:
			_win()
			return

		_spawn_frogger(true)


## Call when player wins the game.
func _win() -> void:
	level_timer.stop()
	var win_scene: PackedScene = load(Constants.WIN_SCREEN_SCENE_PATH)
	get_tree().current_scene.call_deferred("add_child", win_scene.instantiate())
	Session.save_session()


## Call when player looses the game.
func _defeat() -> void:
	level_timer.stop()
	var defeat_scene: PackedScene = load(Constants.DEFEAT_SCREEN_SCENE_PATH)
	get_tree().current_scene.call_deferred("add_child", defeat_scene.instantiate())
	Session.save_session()


## Signal processor of current [Frogger] movement. Checks if current [Frogger] is on "Water" of "Finish" tile.
func _on_frogger_moved() -> void:
	_score += Constants.SCORE_FOR_MOVEMENT
	var local_position: Vector2 = ground_layer.to_local(_frogger.global_position)
	local_position.x = snapped(local_position.x, Constants.STEP_SIZE)
	var tile_position: Vector2i = ground_layer.local_to_map(local_position)
	var tile: TileData = ground_layer.get_cell_tile_data(tile_position)
	_check_is_on_finish(tile, tile_position)
	_check_is_on_water(tile)
