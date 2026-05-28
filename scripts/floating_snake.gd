extends MovingObstacle

@export var variants: Array[AtlasTexture]

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	super._ready()
	sprite.texture = variants.pick_random()
	_resize_collision()


func _resize_collision() -> void:
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = sprite.get_rect().size
	collision_shape.position.y = Constants.STEP_SIZE / 2.0
	collision_shape.position.x = collision_shape.shape.size.x / 2.0
