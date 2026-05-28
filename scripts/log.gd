extends MovingObstacle

@export_range(0, 1, 0.05) var snake_possibility: float

@onready var snake_scene: PackedScene = preload(Constants.SNAKE_SCENE_PATH)


func _ready() -> void:
	if randf() < snake_possibility:
		var snake: Snake = snake_scene.instantiate()
		var possible_pos_idxs: Array = range(sprite.get_rect().size.x / Constants.STEP_SIZE)
		snake.position.x = possible_pos_idxs.pick_random() * Constants.STEP_SIZE
		add_child(snake)
		if direction.x == -1:
			snake.sprite.flip_h = true
	super._ready()
