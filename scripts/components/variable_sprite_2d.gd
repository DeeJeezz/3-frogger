extends Sprite2D
class_name VariableSprite2D


@export var variants: Array[Texture2D]


func _ready() -> void:
	texture = variants.pick_random()
