class_name RowSpawner
extends Node2D

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

@export var variants: Array[PackedScene]
@export var direction: Direction = Direction.RIGHT
@export_group("Speed settings")
@export var min_speed: float
@export var max_speed: float
@export_group("Timing settings")
@export var min_time: float
@export var max_time: float

@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	randomize()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_spawn_object)
	_set_timer()


func _set_timer() -> void:
	spawn_timer.start(randf_range(min_time, max_time))


func _spawn_object() -> void:
	if not variants:
		return
	var object_scene: PackedScene = variants.pick_random()
	var object: MovingObstacle = object_scene.instantiate()
	object.speed = randf_range(min_speed, max_speed)
	object.direction.x = direction
	add_child(object)
	_set_timer()
