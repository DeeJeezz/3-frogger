class_name MovingObstacle
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 100.0

var _player: Node2D

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	if direction.x == -1:
		sprite.flip_h = true


func _process(delta: float) -> void:
	var movement: float = speed * delta * direction.x
	position.x += movement

	if _player:
		_player.position.x += movement

	if global_position.x < -Constants.OBSTACLE_DESTROY_OFFSET or global_position.x > Constants.SCREEN_SIZE.x + Constants.OBSTACLE_DESTROY_OFFSET:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	_player = area.get_parent()


func _on_area_exited(_area: Area2D) -> void:
	_player = null
