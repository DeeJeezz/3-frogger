class_name MovingObstacle
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 100.0

var _frogger: Frogger

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	if direction.x == -1:
		sprite.flip_h = true

	_resize_collision()


func _process(delta: float) -> void:
	var movement: float = speed * delta * direction.x
	position.x += movement

	if _frogger:
		_frogger.position.x += movement

	if global_position.x < -Constants.OBSTACLE_DESTROY_OFFSET or global_position.x > Constants.SCREEN_SIZE.x + Constants.OBSTACLE_DESTROY_OFFSET:
		queue_free()


func _resize_collision() -> void:
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = sprite.get_rect().size
	collision_shape.position.y = Constants.STEP_SIZE / 2.0
	collision_shape.position.x = collision_shape.shape.size.x / 2.0


func _on_frogger_died() -> void:
	_frogger = null


func _on_area_entered(area: Area2D) -> void:
	if collision_layer != Constants.FLOATING_COLLISION_LAYER:
		return

	_frogger = area.get_parent()
	if not _frogger.died.is_connected(_on_frogger_died):
		_frogger.died.connect(_on_frogger_died)


func _on_area_exited(_area: Area2D) -> void:
	_frogger = null
