extends Node

const MAIN_MENU_SCENE_PATH: String = "res://scenes/ui/main_menu.tscn"
const LEVEL_1_SCENE_PATH: String = "res://scenes/levels/level_1.tscn"
const FROGGER_SCENE_PATH: String = "res://scenes/frogger.tscn"
const SNAKE_SCENE_PATH: String = "res://scenes/obstacles/snake.tscn"
const STEP_SIZE: int = 16
const WATER_TILEMAP_LAYER_NAME: String = "Water"
const FINISH_TILEMAP_LAYER_NAME: String = "Finish"
const FLOATING_COLLISION_LAYER: int = 4
const DEATH_COLLISION_LAYER: int = 2
const FROGGER_COLLISION_LAYER: int = 1
const OBSTACLE_DESTROY_OFFSET: float = 150.0

var SCREEN_SIZE: Vector2


func _ready() -> void:
	SCREEN_SIZE = get_viewport().get_visible_rect().size
